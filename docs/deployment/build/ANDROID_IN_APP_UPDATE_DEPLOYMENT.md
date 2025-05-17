# Android Native In-App Updates

For Android native application does not support CodePush, the in-app update functionality is implemented using the Google Play In-App Updates API or a custom solution for apps distributed outside of Google Play.
This document provides a guide on implementing in-app update functionality for native Android applications.

---

## Introduction

Unlike JavaScript-based frameworks that can use CodePush, native Android apps require different approaches for in-app updates:

1. **Google Play In-App Updates API** - Official solution for apps distributed via Google Play
2. **Custom update solutions** - For apps distributed through other channels

---

## Google Play In-App Updates API

### Prerequisites
- Google Play Developer account
- App published on Google Play Store
- Play Core library dependency

### 1. **Add Dependencies**

Add the Play Core library to your app-level `build.gradle`:

```gradle
dependencies {
    implementation 'com.google.android.play:core:1.10.3'
    // For Kotlin coroutines support
    implementation 'com.google.android.play:core-ktx:1.8.1'
}
```

### 2. **Implementation**

Two update flows are available:

#### Flexible Update (Background download with user-triggered install)

```kotlin
class MainActivity : AppCompatActivity() {

    private val appUpdateManager by lazy { AppUpdateManagerFactory.create(applicationContext) }
    private val appUpdateInfoTask by lazy { appUpdateManager.appUpdateInfo }
    private val REQUEST_CODE_FLEXIBLE_UPDATE = 123

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        checkForUpdates()
    }

    private fun checkForUpdates() {
        appUpdateInfoTask.addOnSuccessListener { appUpdateInfo ->
            if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE
                && appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.FLEXIBLE)) {

                appUpdateManager.startUpdateFlowForResult(
                    appUpdateInfo,
                    AppUpdateType.FLEXIBLE,
                    this,
                    REQUEST_CODE_FLEXIBLE_UPDATE
                )

                appUpdateManager.registerListener(installStateUpdatedListener)
            }
        }
    }

    private val installStateUpdatedListener = InstallStateUpdatedListener { state ->
        if (state.installStatus() == InstallStatus.DOWNLOADED) {
            // Show update completed dialog
            popupSnackbarForCompleteUpdate()
        }
    }

    private fun popupSnackbarForCompleteUpdate() {
        Snackbar.make(
            findViewById(R.id.main_layout),
            "An update has just been downloaded.",
            Snackbar.LENGTH_INDEFINITE
        ).apply {
            setAction("INSTALL") { appUpdateManager.completeUpdate() }
            show()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        appUpdateManager.unregisterListener(installStateUpdatedListener)
    }
}
```

#### Immediate Update (Forced update)

```kotlin
private fun checkForImmediateUpdate() {
    appUpdateInfoTask.addOnSuccessListener { appUpdateInfo ->
        if (appUpdateInfo.updateAvailability() == UpdateAvailability.UPDATE_AVAILABLE
            && appUpdateInfo.isUpdateTypeAllowed(AppUpdateType.IMMEDIATE)) {

            appUpdateManager.startUpdateFlowForResult(
                appUpdateInfo,
                AppUpdateType.IMMEDIATE,
                this,
                REQUEST_CODE_IMMEDIATE_UPDATE
            )
        }
    }
}

override fun onResume() {
    super.onResume()

    // Checks if an immediate update is in progress and resume if necessary
    appUpdateManager.appUpdateInfo.addOnSuccessListener { appUpdateInfo ->
        if (appUpdateInfo.updateAvailability() == UpdateAvailability.DEVELOPER_TRIGGERED_UPDATE_IN_PROGRESS) {
            appUpdateManager.startUpdateFlowForResult(
                appUpdateInfo,
                AppUpdateType.IMMEDIATE,
                this,
                REQUEST_CODE_IMMEDIATE_UPDATE
            )
        }
    }
}
```

---

## Custom Update Solution

For apps distributed outside Google Play, implement a custom solution:

### 1. **Create a Version Check API**

Create a REST API endpoint that returns version information:

```json
{
  "latestVersion": "1.2.0",
  "minSupportedVersion": "1.0.0",
  "updateUrl": "https://your-domain.com/app/latest"
}
```

### 2. **Implement Version Checking**

```kotlin
class UpdateChecker(private val context: Context) {

    private val apiService = RetrofitClient.getClient().create(ApiService::class.java)

    fun checkForUpdates(listener: UpdateListener) {
        apiService.getVersionInfo().enqueue(object : Callback<VersionInfo> {
            override fun onResponse(call: Call<VersionInfo>, response: Response<VersionInfo>) {
                response.body()?.let { versionInfo ->
                    val currentVersion = BuildConfig.VERSION_NAME

                    when {
                        isVersionNewer(currentVersion, versionInfo.minSupportedVersion) -> {
                            // Current version is below minimum supported
                            listener.onUpdateRequired(versionInfo.updateUrl)
                        }
                        isVersionNewer(currentVersion, versionInfo.latestVersion) -> {
                            // Update available but not required
                            listener.onUpdateAvailable(versionInfo.updateUrl)
                        }
                        else -> {
                            // App is up to date
                            listener.onNoUpdateAvailable()
                        }
                    }
                }
            }

            override fun onFailure(call: Call<VersionInfo>, t: Throwable) {
                listener.onError(t.message ?: "Unknown error")
            }
        })
    }

    private fun isVersionNewer(current: String, target: String): Boolean {
        // Compare version strings (e.g., "1.0.0" < "1.0.1")
        // Implementation depends on your versioning scheme
        // This is a simplified example
        val currentParts = current.split(".").map { it.toInt() }
        val targetParts = target.split(".").map { it.toInt() }

        for (i in 0 until minOf(currentParts.size, targetParts.size)) {
            if (currentParts[i] < targetParts[i]) return true
            if (currentParts[i] > targetParts[i]) return false
        }

        return currentParts.size < targetParts.size
    }

    interface UpdateListener {
        fun onUpdateRequired(updateUrl: String)
        fun onUpdateAvailable(updateUrl: String)
        fun onNoUpdateAvailable()
        fun onError(message: String)
    }
}
```

### 3. **Implement in Activity**

```kotlin
class MainActivity : AppCompatActivity(), UpdateChecker.UpdateListener {
    
    private lateinit var updateChecker: UpdateChecker
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        
        updateChecker = UpdateChecker(this)
        updateChecker.checkForUpdates(this)
    }
    
    override fun onUpdateRequired(updateUrl: String) {
        AlertDialog.Builder(this)
            .setTitle("Update Required")
            .setMessage("This version is no longer supported. Please update to continue.")
            .setCancelable(false)
            .setPositiveButton("Update") { _, _ -> 
                openUpdateUrl(updateUrl)
            }
            .show()
    }
    
    override fun onUpdateAvailable(updateUrl: String) {
        AlertDialog.Builder(this)
            .setTitle("Update Available")
            .setMessage("A new version is available. Would you like to update?")
            .setPositiveButton("Update") { _, _ -> 
                openUpdateUrl(updateUrl)
            }
            .setNegativeButton("Later", null)
            .show()
    }
    
    override fun onNoUpdateAvailable() {
        // App is up to date
    }
    
    override fun onError(message: String) {
        Log.e("UpdateChecker", "Error checking for updates: $message")
    }
    
    private fun openUpdateUrl(url: String) {
        val intent = Intent(Intent.ACTION_VIEW).apply {
            data = Uri.parse(url)
        }
        startActivity(intent)
    }
}
```

---

## Best Practices

- **Staged Rollouts**: Release updates to a small percentage of users first
- **Version Compatibility**: Ensure backward compatibility of your APIs
- **Forced Updates**: Only require updates for critical security fixes or major API changes
- **User Experience**: Allow users to download updates in the background when possible
- **Testing**: Thoroughly test the update mechanism before release

---

## Troubleshooting

- **Update Failed**: Verify network connectivity and server availability
- **Version Check Issues**: Ensure your versioning scheme is consistent and properly implemented
- **Google Play API Errors**: Check that your app is properly signed and published

For more details, refer to the [Google Play In-App Updates Documentation](https://developer.android.com/guide/playcore/in-app-updates).