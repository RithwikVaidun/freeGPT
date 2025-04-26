function askGPTSmart(prompt)
	hs.application.launchOrFocus("ChatGPT")
	hs.timer.doAfter(1.5, function()
		hs.eventtap.leftClick({ x = 600, y = 1000 }) -- Click input box
		hs.timer.usleep(300000)
		hs.eventtap.keyStrokes(prompt)
		hs.timer.usleep(300000)
		hs.eventtap.keyStroke({}, "return")

		-- Now, monitor for the response to appear
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
	local stableWaitTime = 3 -- seconds to wait after last change

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

		-- If enough time has passed with no new changes, consider it stable
		local timeSinceLastChange = hs.timer.secondsSinceEpoch() - lastChangeTime
		if timeSinceLastChange >= stableWaitTime then
			-- print("No new changes for " .. stableWaitTime .. " seconds. Capturing response...")

			-- Now compare baselineDescriptions vs lastStableDescriptions
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

-- local prompt = "what does it take to get an internship at google?"
-- local prompt = "tell me an interesting fact in one sentence"
-- askGPTSmart(prompt)
