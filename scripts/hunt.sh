#!/usr/bin/env bash
# Outify crash hunt: launch -> deliberate bad login -> relaunch loop -> monkey crawl.
set -uo pipefail

LABEL="${1:-android-unknown}"
PKG="cc.tomko.outify"
ACT="cc.tomko.outify/.MainActivity"
OUT="out/${LABEL}"
mkdir -p "$OUT"
LOG="$OUT/logcat_full.txt"
: > "$LOG"

say() { echo "[$(date -u +%H:%M:%S)] $*" | tee -a "$OUT/steps.txt"; }

adb_bg_logcat() {
  adb logcat -c || true
  adb logcat -v threadtime > "$LOG" 2>&1 &
  echo $! > "$OUT/logcat.pid"
}

snap() {
  adb exec-out screencap -p > "$OUT/$1.png" 2>/dev/null || true
  adb shell uiautomator dump /sdcard/ui.xml >/dev/null 2>&1 || true
  adb pull /sdcard/ui.xml "$OUT/$1.xml" >/dev/null 2>&1 || true
  say "snapshot $1"
}

pid_of() { adb shell pidof "$PKG" 2>/dev/null | tr -d '\r' ; }
alive() { [ -n "$(pid_of)" ]; }

{
  echo "label: $LABEL"
  adb shell getprop ro.build.version.release
  adb shell getprop ro.build.version.sdk
  adb shell getprop ro.product.cpu.abi
  adb shell wm size
  adb shell wm density
} > "$OUT/device.txt" 2>&1
say "device: $(tr '\n' ' ' < "$OUT/device.txt")"

adb_bg_logcat
adb shell settings put global window_animation_scale 0 || true
adb shell settings put global transition_animation_scale 0 || true
adb shell settings put global animator_duration_scale 0 || true

say "install apk"
adb install -r -g outify.apk > "$OUT/install.txt" 2>&1
grep -q "Success" "$OUT/install.txt" || say "INSTALL PROBLEM: $(cat "$OUT/install.txt")"
adb shell pm clear "$PKG" >/dev/null 2>&1 || true

say "launch #1 (fresh)"
adb shell am start -W -n "$ACT" > "$OUT/launch1.txt" 2>&1
sleep 10
snap "01_first_launch"
say "alive after first launch: $(alive && echo yes || echo NO)"

say "attempting login with bogus credentials"
python3 - "$OUT/01_first_launch.xml" > "$OUT/tap_plan.txt" 2>/dev/null <<'PY'
import re,sys,xml.etree.ElementTree as ET
p=sys.argv[1]
try: t=ET.parse(p).getroot()
except Exception: sys.exit(0)
def ctr(n):
    m=re.match(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', n.get('bounds','[0,0][0,0]'))
    if not m: return None
    a,b,c,d=map(int,m.groups()); return ((a+c)//2,(b+d)//2)
edits,btns=[],[]
for n in t.iter('node'):
    txt=(n.get('text') or '')+' '+(n.get('content-desc') or '')
    c=ctr(n)
    if not c: continue
    cls=n.get('class','')
    if 'EditText' in cls: edits.append((c,txt.strip()))
    if re.search(r'log ?in|sign ?in|continue|next|submit',txt,re.I): btns.append((c,txt.strip()))
print("EDITS",edits)
print("BTNS",btns)
for i,(c,_) in enumerate(edits[:2]):
    print(f"TAP {c[0]} {c[1]}")
    print(f"TEXT {'tester.bogus@example.com' if i==0 else 'WrongPass2024'}")
if btns:
    c=btns[0][0]; print(f"TAP {c[0]} {c[1]}")
PY
cat "$OUT/tap_plan.txt" >> "$OUT/steps.txt"

while read -r cmd a b; do
  case "$cmd" in
    TAP)  say "tap $a $b"; adb shell input tap "$a" "$b"; sleep 2 ;;
    TEXT) say "type $a"; adb shell input text "$a"; sleep 1 ;;
  esac
done < <(grep -E '^(TAP|TEXT) ' "$OUT/tap_plan.txt" || true)

sleep 12
snap "02_after_login_attempt"
say "alive after failed login: $(alive && echo yes || echo NO)"

i=1
while [ "$i" -le 5 ]; do
  say "relaunch #$i"
  adb shell am start -n "$ACT" > "$OUT/relaunch_$i.txt" 2>&1
  sleep 7
  snap "03_relaunch_$i"
  if alive; then
    say "relaunch #$i: running (pid $(pid_of))"
  else
    say "relaunch #$i: PROCESS DEAD"
    adb logcat -b crash -d > "$OUT/crashbuf_relaunch_$i.txt" 2>&1 || true
  fi
  i=$((i+1))
done

say "monkey crawl (500 events)"
timeout 420 adb shell monkey -p "$PKG" --throttle 250 --pct-syskeys 0 --pct-appswitch 10 --pct-touch 55 --pct-motion 20 --pct-nav 10 --pct-majornav 5 --ignore-crashes --ignore-timeouts -v 500 > "$OUT/monkey.txt" 2>&1 || say "monkey exited non-zero"
sleep 3
snap "04_after_monkey"

say "bottom navigation sweep"
SIZE=$(adb shell wm size | tr -d '\r' | awk -F'[: ]+' '{print $NF}')
W=$(echo "$SIZE" | cut -dx -f1); H=$(echo "$SIZE" | cut -dx -f2)
if [ -n "${W:-}" ] && [ -n "${H:-}" ]; then
  for f in 10 30 50 70 90; do
    X=$(( W * f / 100 )); Y=$(( H * 95 / 100 ))
    say "tab sweep tap $X $Y"; adb shell input tap "$X" "$Y"; sleep 4
    snap "05_tab_${f}"
    alive || { say "died at tab $f"; adb logcat -b crash -d > "$OUT/crashbuf_tab_$f.txt" 2>&1 || true; adb shell am start -n "$ACT" >/dev/null 2>&1; sleep 6; }
  done
fi

for spec in "85 8" "50 8" "50 50" "50 92"; do
  set -- $spec
  say "deep tap $1 $2"; adb shell input tap "$1" "$2"; sleep 3
done
snap "06_final"

kill "$(cat "$OUT/logcat.pid" 2>/dev/null)" 2>/dev/null || true
sleep 2
adb logcat -b crash -d > "$OUT/crash_buffer.txt" 2>&1 || true
adb shell dumpsys dropbox --print data_app_crash > "$OUT/dropbox_crash.txt" 2>&1 || true
adb shell dumpsys dropbox --print data_app_anr > "$OUT/dropbox_anr.txt" 2>&1 || true
adb shell dumpsys activity exit-info "$PKG" > "$OUT/exit_info.txt" 2>&1 || true

python3 - "$OUT" "$LABEL" <<'PY'
import sys,re,os,glob
out,label=sys.argv[1],sys.argv[2]
txt=""
for f in [os.path.join(out,'logcat_full.txt')]+glob.glob(os.path.join(out,'crash_buffer.txt'))+glob.glob(os.path.join(out,'crashbuf_*.txt')):
    try: txt+=open(f,errors='replace').read()
    except Exception: pass
blocks=re.findall(r'(FATAL EXCEPTION.*?)(?=\n\d\d:\d\d:\d\d\.|\Z)',txt,re.S)
anrs=re.findall(r'(ANR in .*?)(?=\n\d\d:\d\d:\d\d\.|\Z)',txt,re.S)
seen=set();uniq=[]
for b in blocks:
    k=b[:400]
    if k not in seen: seen.add(k); uniq.append(b.strip())
lines=[f"# Crash hunt: {label}","",f"FATAL EXCEPTION blocks: {len(uniq)}",f"ANR blocks: {len(anrs)}",""]
for i,b in enumerate(uniq,1):
    lines+= [f"## Crash {i}","```",b[:4000],"```",""]
for i,b in enumerate(anrs,1):
    lines+= [f"## ANR {i}","```",b[:3000],"```",""]
open(os.path.join(out,'crash_report.md'),'w').write("\n".join(lines))
print(f"{label}: {len(uniq)} crashes, {len(anrs)} ANRs")
PY

say "done"
