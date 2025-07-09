"use client"

import { Button } from "@/components/ui/button"
import { Card, CardContent } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import {
  Calendar,
  Settings,
  Trophy,
  TrendingUp,
  Flame,
  Plus,
  Target,
  Star,
  GitCommit,
  Users,
  ChevronRight,
  Bell,
} from "lucide-react"

export default function GitStreakiOSV2() {
  // Mock data for recent activity
  const recentCommits = [
    { repo: "my-portfolio", message: "Update homepage design", time: "2h ago", commits: 3 },
    { repo: "react-components", message: "Add new button variants", time: "5h ago", commits: 2 },
    { repo: "api-server", message: "Fix authentication bug", time: "1d ago", commits: 1 },
  ]

  // Mock data for weekly activity
  const weeklyData = [
    { day: "Mon", commits: 4, active: true },
    { day: "Tue", commits: 2, active: true },
    { day: "Wed", commits: 6, active: true },
    { day: "Thu", commits: 3, active: true },
    { day: "Fri", commits: 5, active: true },
    { day: "Sat", commits: 1, active: true },
    { day: "Sun", commits: 7, active: true },
  ]

  const achievements = [
    { title: "Week Warrior", description: "7 day streak", icon: "🔥", unlocked: true },
    { title: "Early Bird", description: "Commit before 9 AM", icon: "🌅", unlocked: true },
    { title: "Night Owl", description: "Commit after 10 PM", icon: "🦉", unlocked: false },
  ]

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-black">
      {/* iOS Status Bar */}
      <div className="h-12 bg-transparent"></div>

      {/* Header with Profile */}
      <div className="px-6 py-4">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-4">
            <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-600 rounded-full flex items-center justify-center">
              <span className="text-white font-bold text-lg">JS</span>
            </div>
            <div>
              <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Good morning!</h1>
              <p className="text-gray-500 dark:text-gray-400">Ready to code today?</p>
            </div>
          </div>
          <div className="flex gap-2">
            <Button variant="ghost" size="icon" className="w-10 h-10 rounded-full">
              <Bell className="h-5 w-5 text-gray-600 dark:text-gray-300" />
            </Button>
            <Button variant="ghost" size="icon" className="w-10 h-10 rounded-full">
              <Settings className="h-5 w-5 text-gray-600 dark:text-gray-300" />
            </Button>
          </div>
        </div>

        {/* Current Streak Hero */}
        <Card className="bg-gradient-to-r from-orange-400 to-red-500 border-none shadow-lg mb-6">
          <CardContent className="p-6 text-center">
            <div className="flex items-center justify-center gap-2 mb-2">
              <Flame className="h-8 w-8 text-white" />
              <span className="text-4xl font-bold text-white">7</span>
            </div>
            <p className="text-white/90 font-medium mb-1">Day Streak</p>
            <p className="text-white/70 text-sm">Your best: 23 days</p>
          </CardContent>
        </Card>
      </div>

      <div className="px-6 space-y-6">
        {/* Level Progress */}
        <Card className="bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800">
          <CardContent className="p-5">
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 bg-purple-100 dark:bg-purple-900/30 rounded-full flex items-center justify-center">
                  <Star className="h-5 w-5 text-purple-600 dark:text-purple-400" />
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900 dark:text-white">Level 12</h3>
                  <p className="text-sm text-gray-500 dark:text-gray-400">Code Samurai</p>
                </div>
              </div>
              <Badge
                variant="secondary"
                className="bg-purple-100 text-purple-700 dark:bg-purple-900/30 dark:text-purple-300"
              >
                2,847 XP
              </Badge>
            </div>
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-gray-600 dark:text-gray-400">Progress</span>
                <span className="text-gray-900 dark:text-white font-medium">85%</span>
              </div>
              <div className="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2">
                <div className="bg-purple-500 h-2 rounded-full" style={{ width: "85%" }}></div>
              </div>
              <p className="text-xs text-gray-500 dark:text-gray-400">353 XP to Level 13</p>
            </div>
          </CardContent>
        </Card>

        {/* This Week */}
        <div>
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">This Week</h3>
          <Card className="bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800">
            <CardContent className="p-5">
              <div className="flex justify-between items-center mb-4">
                <span className="text-sm text-gray-600 dark:text-gray-400">Daily Activity</span>
                <span className="text-sm font-medium text-green-600 dark:text-green-400">21 commits</span>
              </div>
              <div className="flex justify-between items-end gap-2">
                {weeklyData.map((day, index) => (
                  <div key={day.day} className="flex flex-col items-center gap-2">
                    <div
                      className={`w-8 rounded-full ${day.active ? "bg-green-500" : "bg-gray-200 dark:bg-gray-700"}`}
                      style={{ height: `${Math.max(day.commits * 8, 16)}px` }}
                    ></div>
                    <span className="text-xs text-gray-500 dark:text-gray-400">{day.day}</span>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Recent Activity */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <h3 className="text-lg font-semibold text-gray-900 dark:text-white">Recent Activity</h3>
            <Button variant="ghost" size="sm" className="text-blue-500">
              View All
              <ChevronRight className="h-4 w-4 ml-1" />
            </Button>
          </div>
          <div className="space-y-3">
            {recentCommits.map((commit, index) => (
              <Card key={index} className="bg-white dark:bg-gray-900 border border-gray-200 dark:border-gray-800">
                <CardContent className="p-4">
                  <div className="flex items-start gap-3">
                    <div className="w-8 h-8 bg-green-100 dark:bg-green-900/30 rounded-full flex items-center justify-center mt-1">
                      <GitCommit className="h-4 w-4 text-green-600 dark:text-green-400" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium text-gray-900 dark:text-white text-sm">{commit.repo}</p>
                      <p className="text-gray-600 dark:text-gray-400 text-sm truncate">{commit.message}</p>
                      <div className="flex items-center gap-4 mt-2">
                        <span className="text-xs text-gray-500 dark:text-gray-400">{commit.time}</span>
                        <Badge variant="outline" className="text-xs">
                          {commit.commits} commit{commit.commits > 1 ? "s" : ""}
                        </Badge>
                      </div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>

        {/* Recent Achievements */}
        <div>
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-4">Achievements</h3>
          <div className="grid grid-cols-1 gap-3">
            {achievements.map((achievement, index) => (
              <Card
                key={index}
                className={`border ${
                  achievement.unlocked
                    ? "bg-white dark:bg-gray-900 border-gray-200 dark:border-gray-800"
                    : "bg-gray-50 dark:bg-gray-800/50 border-gray-100 dark:border-gray-700"
                }`}
              >
                <CardContent className="p-4">
                  <div className="flex items-center gap-3">
                    <span className="text-2xl">{achievement.icon}</span>
                    <div className="flex-1">
                      <h4
                        className={`font-medium ${
                          achievement.unlocked ? "text-gray-900 dark:text-white" : "text-gray-500 dark:text-gray-400"
                        }`}
                      >
                        {achievement.title}
                      </h4>
                      <p className="text-sm text-gray-500 dark:text-gray-400">{achievement.description}</p>
                    </div>
                    {achievement.unlocked && (
                      <Badge className="bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-300">
                        Unlocked
                      </Badge>
                    )}
                  </div>
                </CardContent>
              </Card>
            ))}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="grid grid-cols-2 gap-4 pb-24">
          <Button className="h-16 bg-blue-500 hover:bg-blue-600 text-white rounded-2xl flex flex-col gap-1">
            <Plus className="h-6 w-6" />
            <span className="text-sm font-medium">Log Commit</span>
          </Button>
          <Button className="h-16 bg-green-500 hover:bg-green-600 text-white rounded-2xl flex flex-col gap-1">
            <Target className="h-6 w-6" />
            <span className="text-sm font-medium">Set Goal</span>
          </Button>
        </div>
      </div>

      {/* iOS Tab Bar */}
      <div className="fixed bottom-0 left-0 right-0 bg-white/95 dark:bg-gray-900/95 backdrop-blur-xl border-t border-gray-200 dark:border-gray-800">
        <div className="flex items-center justify-around py-3 px-6">
          <Button variant="ghost" className="flex flex-col items-center gap-1 text-blue-500">
            <Calendar className="h-6 w-6" />
            <span className="text-xs font-medium">Home</span>
          </Button>
          <Button variant="ghost" className="flex flex-col items-center gap-1 text-gray-400">
            <Trophy className="h-6 w-6" />
            <span className="text-xs">Awards</span>
          </Button>
          <Button variant="ghost" className="flex flex-col items-center gap-1 text-gray-400">
            <TrendingUp className="h-6 w-6" />
            <span className="text-xs">Stats</span>
          </Button>
          <Button variant="ghost" className="flex flex-col items-center gap-1 text-gray-400">
            <Users className="h-6 w-6" />
            <span className="text-xs">Social</span>
          </Button>
        </div>
        <div className="h-1"></div>
      </div>
    </div>
  )
}
