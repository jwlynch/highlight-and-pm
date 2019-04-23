-- (C) 2016-2017 Patrick Griffis <tingping@tingping.se>
-- (C) 2017 Svetlana Tkachenko <svetlana@members.fsf.org>
-- Derived work from pmcolor.lua (by Patrick Griffis)
--   Include PMs (2017/11/12, S.T.)
--   Include Private Actions (2019/04/23, S.T.)
-- 
-- The MIT License (MIT)
-- Permission is hereby granted, free of charge, to any person obtaining a copy of
-- this software and associated documentation files (the "Software"), to deal in
-- the Software without restriction, including without limitation the rights to
-- use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
-- the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
-- FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
-- COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
-- IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
-- CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

hexchat.register('Highlights (including PMs)', '1.1', 'Prints highlights to another tab')

local TAB_NAME = '(highlights)'
local OPEN_PER_SERVER = false

local function find_highlighttab ()
	local network = nil
	if OPEN_PER_SERVER then
		network = hexchat.get_info('network')
	end
	local ctx = hexchat.find_context(network, TAB_NAME)
	if not ctx then
		if OPEN_PER_SERVER then
			hexchat.command('query -nofocus ' .. TAB_NAME)
		else
			local newtofront = hexchat.prefs['gui_tab_newtofront']
			hexchat.command('set -quiet gui_tab_newtofront off')
			hexchat.command('newserver -noconnect ' .. TAB_NAME)
			hexchat.command('set -quiet gui_tab_newtofront ' .. tostring(newtofront))
		end

		return hexchat.find_context(network, TAB_NAME)
	end

	return ctx
end

local function on_highlight (args, event_type)
	local channel = hexchat.get_info('channel')
	local highlight_context = find_highlighttab()

	local format
	if event_type == 'Channel Msg Hilight' then
		format = '\00322%s\t\00318<%s%s%s>\015 %s'
	elseif event_type == 'Channel Action Hilight' then
		format = '\00322%s\t\002\00318%s%s%s\015 %s'
	elseif event_type == 'Private Message to Dialog' then
		format = '\00322%s\t\00318<%s%s%s>\015 %s'
	elseif event_type == 'Private Action to Dialog' then
		format = '\00322%s\t\002\00318<%s%s%s>\015 %s'
	end

	highlight_context:print(string.format(format, channel,
	                       args[3] or '', args[4] or '', hexchat.strip(args[1]), args[2]))
	highlight_context:command('gui color 0') -- Ignore colors
end

for _, event in ipairs({'Channel Msg Hilight', 'Channel Action Hilight'}) do
	hexchat.hook_print(event, function (args)
		return on_highlight(args, event)
	end, hexchat.PRI_LOW)
end



for _, event in pairs({'Private Message to Dialog', 'Private Action to Dialog'}) do
	hexchat.hook_print(event, function (args)
		return on_highlight(args, event)
	end)
end
