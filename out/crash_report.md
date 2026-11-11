# Crash hunt: android-13

FATAL EXCEPTION blocks: 1
ANR blocks: 0

## Crash 1
```
FATAL EXCEPTION: DefaultDispatcher-worker-8
11-11 16:24:16.357  3366  3403 E AndroidRuntime: Process: cc.tomko.outify, PID: 3366
11-11 16:24:16.357  3366  3403 E AndroidRuntime: java.lang.UnsatisfiedLinkError: No implementation found for void cc.tomko.outify.LibrespotFfi.libInit(android.content.Context, java.lang.String, java.lang.String) (tried Java_cc_tomko_outify_LibrespotFfi_libInit and Java_cc_tomko_outify_LibrespotFfi_libInit__Landroid_content_Context_2Ljava_lang_String_2Ljava_lang_String_2)
11-11 16:24:16.357  3366  3403 E AndroidRuntime: 	at cc.tomko.outify.LibrespotFfi.libInit(Native Method)
11-11 16:24:16.357  3366  3403 E AndroidRuntime: 	at cc.tomko.outify.OutifyApplication$a.r(r8-map-id-1ef5eb0dd71ba25cabb28dc9bec35103170d97d08be8b7c5283083dc95ac3c93:77)
11-11 16:24:16.357  3366  3403 E AndroidRuntime: 	at ka0.m(r8-map-id-1ef5eb0dd71ba25cabb28dc9bec35103170d97d08be8b7c5283083dc95ac3c93:8)
11-11 16:24:16.357  3366  3403 E AndroidRuntime: 	at x42.run(r8-map-id-1ef5eb0dd71ba25cabb28dc9bec35103170d97d08be8b7c5283083dc95ac3c93:114)
11-11 16:24:16.357  3366  3403 E AndroidRuntime: 	at gi4$a.run(r8-map-id-1ef5eb0dd71ba25cabb28dc9bec35103170d97d08be8b7c5283083dc95ac3c93:4)
11-11 16:24:16.357  3366  3403 E AndroidRuntime: 	at px8.run(r8-map-id-1ef5eb0dd71ba25cabb28dc9bec35103170d97d08be8b7c5283083dc95ac3c93:3)
11-11 16:24:16.357  3366  3403 E AndroidRuntime: 	at ir1$a.run(r8-map-id-1ef5eb0dd71ba25cabb28dc9bec35103170d97d08be8b7c5283083dc95ac3c93:94)
11-11 16:24:16.357  3366  3403 E AndroidRuntime: 	Suppressed: z32: [kn8{Cancelling}@dbac780, Dispatchers.IO]
11-11 16:24:16.360   282   314 I netd    : tetherGetStats() -> {[]} <0.33ms>
11-11 16:24:16.380   471  1784 D CompatibilityChangeReporter: Compat change id reported: 161252188; UID 10088; state: DISABLED
11-11 16:24:16.385   471   514 D CompatibilityChangeReporter: Compat change id reported: 135634846; UID 10088; state: DISABLED
11-11 16:24:16.385   471   514 D CompatibilityChangeReporter: Compat change id reported: 177438394; UID 10088; state: DISABLED
11-11 16:24:16.385   471   514 D CompatibilityChangeReporter: Compat change id reported: 135772972; UID 10088; state: DISABLED
11-11 16:24:16.385   471   514 D CompatibilityChangeReporter: Compat change id reported: 135754954; UID 10088; state: ENABLED
11-11 16:24:16.386   471   515 D CompatibilityChangeReporter: Compat change id reported: 143937733; UID 10088; state: ENABLED
11-11 16:24:16.393   286   286 D Zygote  : Forked child process 3411
11-11 16:24:16.395   471   515 I ActivityManager: Start proc 3411:com.android.carrierdefaultapp/u0a88 for broadcast {com.android.carrierdefaultapp/com.android.carrierdefaultapp.CarrierDefaultBroadcastReceiver}
11-11 16:24:16.425  3411  3411 I rrierdefaultapp: Using CollectorTypeCC GC.
11-11 16:24:16.428  3411  3411 W rrierdefaultapp: Unexpected CPU variant for x86: x86_64.
11-11 16:24:16.428  3411  3411 W rrierdefaultapp: Known variants: atom, sandybridge, silvermont, kabylake, default
11-11 16:24:16.436  3366  3409 D libEGL  : loaded /vendor/lib64/egl/libEGL_emulation.so
11-11 16:24:16.439  3366  3409 D libEGL  : loaded /vendor/lib64/egl/libGLESv1_CM_emulation.so
11-11 16:24:16.447  3366  3409 D libEGL  : loaded /vendor/lib64/egl/libGLESv2_emulation.so
11-11 16:24:16.465   471   582 E RoleControllerManager: Error calling grantDefaultRoles()
11-11 16:24:16.465   471   582 E RoleControllerManager: java.util.concurrent.TimeoutException
11-11 16:24:16.465   471   582 E RoleControllerManager: 	at com.android.permission.jarjar.com.android.internal.infra.AndroidFuture.triggerTimeout(AndroidFuture.java:289)
11-11 16:24:16.465   471   582 E RoleControllerManager: 	at com.android.permission.jarjar.com.android.internal.infra.AndroidFuture$$ExternalSyntheticLambda2.run(Unknown Source:2)
11-11 16:24:16.465   471   582 E RoleControllerManager: 	at android.os.Handler.handleCallback(Handler.java:942)
11-11 16:24:16.465   471   582 E RoleControllerManager: 	at android.os.Handler.dispatchMessage(Han
```
