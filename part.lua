rstChild("HumanoidRootPart").Position).Magnitude
                                if distance < minDistance then
                                    selectedTarget = target
                                    minDistance = distance
                                end
                            end
                            lastAttackedTargets = {}
                        end
                        currentTarget = selectedTarget
                        table.insert(lastAttackedTargets, currentTarget)
                    else
                        local closestTarget = nil
                        local minDistance = killAuraRange
                        for _, target in ipairs(validTargets) do
                            local distance = (rootPart.Position - target:FindFirstChild("HumanoidRootPart").Position).Magnitude
                            if distance < minDistance then
                                closestTarget = target
                                minDistance = distance
                            end
                        end
                        currentTarget = closestTarget
                    end
                else
                    currentTarget = nil
                    lastAttackedTargets = {}
                    lastSelectedTarget = nil
                end

                highlight.Parent = currentTarget

                if currentTarget then
                    local targetRoot = currentTarget:FindFirstChild("HumanoidRootPart")
                    local targetHumanoid = currentTarget:FindFirstChild("Humanoid")
                    if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                        local currentTime = tick()
                        local shouldTeleport = false
                        if attackMultipleTargets and currentTarget ~= lastSelectedTarget then
                            if currentTime - lastMultiTargetTeleportTime >= multiTargetTeleportCooldown then
                                shouldTeleport = true
                                lastMultiTargetTeleportTime = currentTime
                            end
                        elseif currentTime - lastTeleportTime >= teleportCooldown then
                            shouldTeleport = true
                            lastTeleportTime = currentTime
                        end

                        if shouldTeleport then
                            local waitTime = math.random(10, 30) / 100
                            task.wait(waitTime)
                            local targetCFrame = targetRoot.CFrame
                            local teleportPosition
                            if killAuraMode == "Behind" then
                                teleportPosition = targetCFrame.Position - targetCFrame.LookVector * 3
                            else
                                teleportPosition = Vector3.new(targetCFrame.Position.X, targetCFrame.Position.Y - 0.1, targetCFrame.Position.Z)
                            end
                            local lookAtPosition = Vector3.new(targetRoot.Position.X, rootPart.Position.Y, targetRoot.Position.Z)
                            local baseCFrame = CFrame.new(teleportPosition, lookAtPosition)
                            rootPart.CFrame = baseCFrame * CFrame.Angles(0, math.rad(30), 0)
                        end

                        if targetStrafeEnabled and currentTarget then
                            local targetRoot = currentTarget:FindFirstChild("HumanoidRootPart")
                            if targetRoot then
                                local angle = tick() * strafeSpeed
                                local targetCFrame = targetRoot.CFrame
                                local strafePosition
                                local targetTool = currentTarget:FindFirstChildOfClass("Tool")
                                local isTargetAttacking = targetTool and targetTool:FindFirstChild("Handle") and 
                                    targetHumanoid:FindFirstChild("Animator") and 
                                    #targetHumanoid.Animator:GetPlayingAnimationTracks() > 0

                                local targetHeight = killAuraMode == "UnderFeet" and targetRoot.Position.Y - 0.1 or targetRoot.Position.Y

                                if smartStrafeEnabled and isTargetAttacking then
                                    local basePosition = targetRoot.Position
                                    local retreatDistance = strafeDistance * 2
                                    local lookVector = targetCFrame.LookVector
                                    strafePosition = basePosition - (lookVector * retreatDistance)
                                else
                                    local relativeOffset = Vector3.new(
                                        math.sin(angle) * strafeDistance,
                                        killAuraMode == "UnderFeet" and 0.5 or 0,
                    