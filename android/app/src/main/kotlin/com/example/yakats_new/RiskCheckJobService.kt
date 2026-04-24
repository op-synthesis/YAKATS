package com.example.yakats_new

import android.app.job.JobInfo
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.ComponentName
import android.content.Context
import android.os.Build
import android.util.Log
import androidx.annotation.RequiresApi
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

@RequiresApi(Build.VERSION_CODES.LOLLIPOP)
class RiskCheckJobService : JobService() {

    companion object {
        private const val JOB_ID = 123
        private const val TAG = "RiskCheckJob"

        // Schedule the job
        fun scheduleJob(context: Context) {
            Log.d(TAG, "🔵 Scheduling job...")

            val jobScheduler = context
                .getSystemService(Context.JOB_SCHEDULER_SERVICE) as JobScheduler

            val jobInfo = JobInfo.Builder(
                JOB_ID,
                ComponentName(context, RiskCheckJobService::class.java)
            )
                .setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY)
                .setPeriodic(15 * 60 * 1000L) // 15 minutes
                .setPersisted(true)
                .setRequiresBatteryNotLow(false)
                .setRequiresDeviceIdle(false)
                .build()

            jobScheduler.schedule(jobInfo)
            Log.d(TAG, "🟢 Job scheduled successfully")
        }

        // Cancel the job
        fun cancelJob(context: Context) {
            Log.d(TAG, "🔵 Canceling job...")

            val jobScheduler = context
                .getSystemService(Context.JOB_SCHEDULER_SERVICE) as JobScheduler
            jobScheduler.cancel(JOB_ID)

            Log.d(TAG, "🟢 Job canceled")
        }
    }

    override fun onStartJob(params: JobParameters?): Boolean {
        Log.d(TAG, "🔵 Job started!")

        GlobalScope.launch {
            try {
                performRiskCheck()
                jobFinished(params, false)
            } catch (e: Exception) {
                Log.e(TAG, "🔴 Job error: ${e.message}")
                jobFinished(params, true)
            }
        }

        return true
    }

    override fun onStopJob(params: JobParameters?): Boolean {
        Log.d(TAG, "🟠 Job stopped")
        return true
    }

    private suspend fun performRiskCheck() {
        Log.d(TAG, "🔵 Performing risk check...")

        try {
            // Risk check logic handled on Flutter side via MethodChannel
            Log.d(TAG, "🟢 Risk check completed")
        } catch (e: Exception) {
            Log.e(TAG, "🔴 Check error: ${e.message}")
        }
    }
}