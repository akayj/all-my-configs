#!/usr/bin/env bash

set -eu

# 获取蓝牙触摸板的电量百分比
battery_percent=$(ioreg -l | grep BatteryPercent | awk '{print $NF}')

if ((battery_percent < 50)); then
	# 获取当前的status-right配置
	current_status_right=$(tmux show-option -gqv status-right)

	if ((battery_percent < 30)); then
		# 在status-right配置的末尾添加电量信息
		new_status_right="$current_status_right #[fg=red]Touchpad:$battery_percent%"
	else
		new_status_right="$current_status_right #[fg=yellow]Touchpad:$battery_percent%"
	fi

	# 更新status-right配置
	tmux set-option -g status-right "$new_status_right"
fi
