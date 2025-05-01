function askGPTSmart(prompt)
	hs.application.launchOrFocus("ChatGPT")
	hs.timer.doAfter(1.5, function()
		hs.eventtap.leftClick({ x = 600, y = 1000 })
		hs.timer.usleep(300000)
		hs.eventtap.keyStrokes(prompt)
		hs.timer.usleep(300000)
		hs.eventtap.keyStroke({}, "return")

		watchForResponse("ChatGPT")
	end)
end

function watchForResponse(appName)
	local app = hs.application.find(appName)
	if not app then
		print("App not found: " .. appName)
		return
	end

	local ui = hs.axuielement.applicationElement(app)
	local baselineDescriptions = collectDescriptions(ui)

	local lastStableDescriptions = baselineDescriptions
	local lastChangeTime = hs.timer.secondsSinceEpoch()
	local stableWaitTime = 3

	local filepath = os.getenv("HOME") .. "/rithwik/projects/auto_gpt/text.md"

	local watcher
	watcher = hs.timer.doEvery(1, function()
		local freshUI = hs.axuielement.applicationElement(app)
		local currentDescriptions = collectDescriptions(freshUI)

		if not areTablesEqual(lastStableDescriptions, currentDescriptions) then
			-- New change detected
			lastStableDescriptions = currentDescriptions
			lastChangeTime = hs.timer.secondsSinceEpoch()
			-- print("Change detected, updating lastChangeTime...")
		end

		local timeSinceLastChange = hs.timer.secondsSinceEpoch() - lastChangeTime
		if timeSinceLastChange >= stableWaitTime then
			local newContent = getNewDescriptions(baselineDescriptions, lastStableDescriptions)

			local file, err = io.open(filepath, "w")
			if not file then
				print("Failed to open file: " .. tostring(err))
				watcher:stop()
				return
			end

			for i, desc in ipairs(newContent) do
				file:write(desc .. "\n")
				print(desc)
			end

			file:close()

			watcher:stop()
		else
			-- print("Waiting... (" .. string.format("%.1f", timeSinceLastChange) .. "s since last change)")
		end
	end)
end

function getNewDescriptions(baseline, latest)
	local newOnes = {}
	local baselineSet = {}
	for _, desc in ipairs(baseline) do
		baselineSet[desc] = true
	end
	for _, desc in ipairs(latest) do
		if not baselineSet[desc] then
			table.insert(newOnes, desc)
		end
	end
	return newOnes
end

function collectDescriptions(ui)
	local descriptions = {}
	local function findDescriptions(el)
		if el:attributeValue("AXRole") == "AXStaticText" then
			local description = el:attributeValue("AXDescription")
			if description then
				table.insert(descriptions, tostring(description))
			end
		end
		local children = el:attributeValue("AXChildren")
		if children then
			for _, child in ipairs(children) do
				findDescriptions(child)
			end
		end
	end
	findDescriptions(ui)
	return descriptions
end

function areTablesEqual(t1, t2)
	if #t1 ~= #t2 then
		return false
	end
	for i = 1, #t1 do
		if t1[i] ~= t2[i] then
			return false
		end
	end
	return true
end

function findButtonByHelp(el, helpText)
	if not el then
		return nil
	end

	local ok, role = pcall(function()
		return el:attributeValue("AXRole")
	end)
	if ok and role == "AXButton" then
		local ok, help = pcall(function()
			return el:attributeValue("AXHelp")
		end)
		if ok and help == helpText then
			return el
		end
	end

	local children = {}
	local ok, kids = pcall(function()
		return el:attributeValue("AXChildren")
	end)
	if ok and kids then
		children = kids
	end

	for _, child in ipairs(children) do
		local f = findButtonByHelp(child, helpText)
		if f then
			return f
		end
	end

	return nil
end

function selectModel(modelKey)
	local frameData = modelMap[modelKey]
	if not frameData then
		hs.alert.show("Unknown model: " .. modelKey)
		return
	end

	local app = hs.application.find("ChatGPT")
	if not app then
		hs.alert.show("ChatGPT not running")
		return
	end

	hs.application.launchOrFocus("ChatGPT")

	hs.timer.doAfter(0.5, function()
		local mainRoot = hs.axuielement.applicationElement(app)

		local picker = findButtonByHelp(mainRoot, "Pick a model or GPT")
		if not picker then
			hs.alert.show("Couldn't find the model picker")
			return
		end

		picker:performAction("AXPress")

		hs.timer.doAfter(1.0, function()
			-- Calculate the center of the button
			local centerX = frameData.x + (frameData.w / 2)
			local centerY = frameData.y + (frameData.h / 2)

			hs.mouse.absolutePosition({ x = centerX, y = centerY })
			hs.timer.doAfter(0.3, function()
				hs.eventtap.leftClick({ x = centerX, y = centerY })
				hs.alert.show("Selected model: " .. modelKey)
			end)
		end)
	end)
end

modelMap = {
	["4o"] = { x = 506, y = 681, w = 300, h = 51 },
	["o3"] = { x = 506, y = 737, w = 300, h = 51 },
	["o4"] = { x = 506, y = 793, w = 300, h = 51 },
	["o4 mini high"] = { x = 506, y = 849, w = 300, h = 51 },
}

-- local prompt = "what does it take to get an internship at google?"
-- local prompt = "tell me an interesting fact in one sentence"
-- askGPTSmart(prompt)
