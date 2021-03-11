package com.example.smart_file_manager

import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import androidx.core.content.ContextCompat.*
import java.io.File
import android.content.pm.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "dev.mayurnile.smartfilemanager/storage"

    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        val list = packageManager.queryIntentActivities(intent, 0)
        val pm: PackageManager = getPackageManager()
        val packages: List<ApplicationInfo> = pm.getInstalledApplications(PackageManager.GET_META_DATA)


        GeneratedPluginRegistrant.registerWith(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
                .setMethodCallHandler { call, result ->
                    when {
                        call.method == "getStorageFreeSpace" -> result.success(getStorageFreeSpace())
                        call.method == "getStorageTotalSpace" -> result.success(getStorageTotalSpace())
                        call.method == "getExternalStorageTotalSpace" -> result.success(getExternalStorageTotalSpace())
                        call.method == "getExternalStorageFreeSpace" -> result.success(getExternalStorageFreeSpace())
                        call.method == "getApps" -> result.success(getApps(packages))
                    }
                }
    }


    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    fun getStorageTotalSpace(): Long {
        val path = Environment.getDataDirectory()
        val stat = StatFs(path.path)
        return stat.totalBytes
    }

    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    fun getStorageFreeSpace(): Long {
        val path = Environment.getDataDirectory()
        val stat = StatFs(path.path)
        Log.i("Internal", path.path)
        return stat.availableBytes
    }

    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    fun getExternalStorageTotalSpace(): Long {
        val dirs: Array<File> = getExternalFilesDirs(context, null)
        val stat = StatFs(dirs[1].path.split("Android")[0])
        return stat.totalBytes
    }

    @RequiresApi(Build.VERSION_CODES.JELLY_BEAN_MR2)
    fun getExternalStorageFreeSpace(): Long {
        val dirs: Array<File> = getExternalFilesDirs(context, null)
        val stat = StatFs(dirs[1].path.split("Android")[0])
        return stat.availableBytes
    }

    fun getApps(List: List<ApplicationInfo>): HashMap<String, Long> {
        val appData = HashMap<String, Long>()
        for (packageInfo in List) {
            val packageName = packageInfo.packageName
            // return size in form of Bytes(Long)
            val size = File(packageManager.getApplicationInfo(packageName, 0).publicSourceDir).length()
            val item = size
            appData.put(packageName, item)
        }
        return appData
    }
}
