package com.example.seima

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class SeimaWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_NEW_THOUGHT = "com.example.seima.ACTION_NEW_THOUGHT"
        const val ACTION_OPEN_SEIMA = "com.example.seima.ACTION_OPEN_SEIMA"
        const val EXTRA_WIDGET_ACTION = "widget_action"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    private fun updateAppWidget(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
    ) {
        val views = RemoteViews(context.packageName, R.layout.seima_widget_layout)

        // New Thought button -> opens app to quick capture
        val newThoughtIntent = Intent(context, MainActivity::class.java).apply {
            action = ACTION_NEW_THOUGHT
            putExtra(EXTRA_WIDGET_ACTION, ACTION_NEW_THOUGHT)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val newThoughtPendingIntent = PendingIntent.getActivity(
            context,
            0,
            newThoughtIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        views.setOnClickPendingIntent(R.id.widget_action_new_thought, newThoughtPendingIntent)

        // Open Seima button -> opens app to main page
        val openSeimaIntent = Intent(context, MainActivity::class.java).apply {
            action = ACTION_OPEN_SEIMA
            putExtra(EXTRA_WIDGET_ACTION, ACTION_OPEN_SEIMA)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val openSeimaPendingIntent = PendingIntent.getActivity(
            context,
            1,
            openSeimaIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        views.setOnClickPendingIntent(R.id.widget_action_open_seima, openSeimaPendingIntent)

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}
