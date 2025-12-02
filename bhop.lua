workspace.Gravity = 95
local Config = {
    --[[General]]
    VISUALIZE_FEET_HB = false, -- Visualize Feet Hitbox
    VISUALIZE_COLLIDE_AND_SLIDE = false,
    STEP_OFFSET = 1.2,
    MASS = 16,
    AIR_FRICTION = 0.4,
    FRICTION = 6,
    GRAVITY = 10,
    JUMP_VELOCITY = 30,
    --[[Accel/Deccel]]
    GROUND_ACCEL = 14,
    GROUND_DECCEL = 10,
    AIR_ACCEL = 52,
    --[[General Speed]]
    AIR_SPEED = 16,
    RUN_SPEED = 16,
    WALK_SPEED = 16,
    CROUCH_SPEED = 10,
    --[[Advanced Speed]]
    AIR_MAX_SPEED = 19.1,        -- The speed at which AIR_MAX_SPEED_FRIC is applied.
    AIR_MAX_SPEED_FRIC = 3,      -- The initial friction applied at max speed
    AIR_MAX_SPEED_FRIC_DEC = .5, -- Amount multiplied to current max speed friction per 1/60sec
    MIN_SLOPE_ANGLE = 40,
    MAX_SLOPE_ANGLE = 75,
    --[[Misc (Don't worry about these)]]
    LEG_HEIGHT = 1.9+.3,
    TORSO_TO_FEET = 3.1+1.9,
    FEET_HB_SIZE = Vector3.new(1,0.1,1),
    TORSO_HB_SIZE = Vector3.new(3,1,3),
    FOOT_OFFSET_AMOUNT = 1.2
}

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local ids = {   
    "rbxassetid://7338942417",
    "rbxassetid://7338942345",
    "rbxassetid://7338942259",
    "rbxassetid://7338942180",
    "rbxassetid://7338942417",
}

local sounds = {}
for _, i in ipairs(ids) do
    local sound = Instance.new("Sound")
    sound.SoundId = i
    sound.Volume = 2
    sound.Parent = game.Workspace  -- Or another appropriate parent
    table.insert(sounds, sound)
end

-- Types are not exported in Lua - just use them locally
local Movement = {}
local Physics = {}
local Shared = {}
local Collisions = {}

local Vec3Mod = {}
Vec3Mod.__index = Vec3Mod

function Vec3Mod.new(input)
    input = input or Vector3.zero
    return setmetatable({x = input.X, y = input.Y, z = input.Z}, Vec3Mod)
end

function Vec3Mod:ToVector3()
    return Vector3.new(self.x, self.y, self.z)
end

local function visualizeRayResult(result, origin, direction)
    local position = result and result.Position or (origin + direction)
    local distance = (origin - position).Magnitude
    local p = Instance.new("Part")
    p.Anchored = true
    p.CanCollide = false
    p.Size = Vector3.new(0.1, 0.1, distance)
    p.CFrame = CFrame.lookAt(origin, position)*CFrame.new(0, 0, -distance/2)
    p.Parent = workspace.Temp
    return p
end

local function flattenVectorAgainstWall(moveVector, normal)
    -- if magnitudes are 0 then just nevermind
    if moveVector.Magnitude == 0 and normal.Magnitude == 0 then
        return Vector3.zero
    end
    
    -- unit the normal (i its already normalized idk)
    normal = normal.Unit
    
    -- reflect the vector
    local reflected = moveVector - 2 * moveVector:Dot(normal) * normal
    
    -- add the reflection to the move vector = vector parallel to wall
    local parallel = moveVector + reflected
    
    -- if magnitude 0 NEVERMIND!!!
    if parallel.Magnitude == 0 then
        return Vector3.zero
    end
    
    -- reduce the parallel vector to make sense idk HorseNuggetsXD did all this thank u
    local cropped = parallel.Unit:Dot(moveVector.Unit) * parallel.Unit * moveVector.Magnitude
    return cropped
end

function Collisions:CollideAndSlide(wishedSpeed)
    local mod = 1
    if wishedSpeed.Magnitude == 0 then
        return wishedSpeed
    end
    
    -- get input vector
    local inputVec = self.states.input_vec
    local newSpeed = wishedSpeed
    local hrp = self.player.Character.HumanoidRootPart
    
    -- raycast var
    local params = Shared.GetMovementParams(self)
    
    -- wished speed modifier
    wishedSpeed = wishedSpeed * 2
    
    -- direction amount var
    local dirAmnt = 1.375 * (mod or 1)
    local mainDirAmnt = 1.55 * (mod or 1)
    
    -- stick var
    local isSticking = false
    local normals = {}
    local stickingDirections = {}
    local ldd = {dir = false, dist = false} -- lowest distance direction
    local partsAlreadyHit = {}
    
    -- destroy sticking visualizations
    if Config.VISUALIZE_COLLIDE_AND_SLIDE then
        for _, v in pairs(self.vis_coll_parts) do
            v:Destroy()
        end
    end
    
    local lookVecs = {
        Vector3.new(0, (-Config.TORSO_TO_FEET) + Config.STEP_OFFSET, 0),
        Vector3.new(0, 0, 0),
        Vector3.new(0, 2, 0)
    }
    
    for _, v in pairs(lookVecs) do
        local values = {}
        local hval = {}
        local currForDir
        local currSideDir
        local rayPos
        
        if typeof(v) == "Vector3" then
            rayPos = hrp.Position + v
        else
            rayPos = Vector3.new(hrp.Position.X, hrp.Parent[v].CFrame.Position, hrp.Position.Z)
        end
        
        -- right, front, back
        if inputVec.X > 0 then
            currForDir = hrp.CFrame.RightVector
            table.insert(values, currForDir)
            table.insert(hval, hrp.CFrame.LookVector * dirAmnt)
            table.insert(hval, -hrp.CFrame.LookVector * dirAmnt)
        -- left, front, back
        elseif inputVec.X < 0 then
            currForDir = -hrp.CFrame.RightVector
            table.insert(values, currForDir)
            table.insert(hval, hrp.CFrame.LookVector * dirAmnt)
            table.insert(hval, -hrp.CFrame.LookVector * dirAmnt)
        end
        
        -- back, left, right
        if inputVec.Z > 0 then
            currSideDir = -hrp.CFrame.LookVector
            table.insert(values, currSideDir)
            table.insert(hval, hrp.CFrame.RightVector * dirAmnt)
            table.insert(hval, -hrp.CFrame.RightVector * dirAmnt)
        -- front, left, right
        elseif inputVec.Z < 0 then
            currSideDir = hrp.CFrame.LookVector
            table.insert(values, currSideDir)
            table.insert(hval, hrp.CFrame.RightVector * dirAmnt)
            table.insert(hval, -hrp.CFrame.RightVector * dirAmnt)
        end
        
        if inputVec.Z == 0 and inputVec.X == 0 then
            values[1] = wishedSpeed.Unit
            table.insert(hval, CFrame.new(wishedSpeed.Unit).RightVector * dirAmnt)
            table.insert(hval, -CFrame.new(wishedSpeed.Unit).RightVector * dirAmnt)
        else
            table.insert(values, wishedSpeed.Unit * dirAmnt)
        end
        
        -- middle directions
        if currForDir and currSideDir then
            for a, b in pairs(values) do
                values[a] = b * mainDirAmnt
            end
            table.insert(values, (currForDir+currSideDir) * mainDirAmnt)
        else
            values[1] = values[1] * mainDirAmnt
            table.insert(values, (values[1] + hval[1]).Unit * mainDirAmnt)
            table.insert(values, (values[1] + hval[2]).Unit * mainDirAmnt)
            table.insert(values, hval[1])
            table.insert(values, hval[2])
        end
        
        for _, b in pairs(values) do
            if not b then continue end
            
            -- visualize ray using pos and direction
            if Config.VISUALIZE_COLLIDE_AND_SLIDE then
                table.insert(self.vis_coll_parts, visualizeRayResult(false, rayPos, b))
            end
            
            local result = workspace:Raycast(rayPos, b, params)
            if not result then continue end
            
            if (not ldd.dir or not ldd.dist) or (ldd.dist and ldd.dist < result.Distance) then
                ldd.dir = b
                ldd.dist = result.Distance
            end
            
            -- don't collide with the same part twice
            if table.find(partsAlreadyHit, result.Instance) then continue end
            table.insert(partsAlreadyHit, result.Instance)
            
            -- get the movement direction compared to the wall
            local _v = newSpeed.Unit * result.Normal
            
            -- find active coordinate of comparison
            for _, c in pairs({_v.X, _v.Y, _v.Z}) do
                if math.abs(c) > 0 then
                    _v = c
                    break
                end
            end
            
            -- if we are moving AWAY from the normal, (positive)
            -- then do not flatten the vector.
            -- it's not necessary.
            -- you will stick.
            -- stick.
            if type(_v) == "number" and _v > 0 then
                continue
            end
            
            if not isSticking then isSticking = true end
            newSpeed = flattenVectorAgainstWall(newSpeed, result.Normal)
            newSpeed = newSpeed - result.Instance.Velocity
            self.mover.PlaneVelocity = Vector2.new(newSpeed.X, newSpeed.Z)
        end
    end
    
    return newSpeed, isSticking and normals, isSticking and stickingDirections, isSticking and ldd.dir
end

local function HandleVisualization(self, cf, size)
    if not Config.VISUALIZE_FEET_HB then
        return
    end
    
    if not self.vispart then
        self.vispart = Instance.new("Part", self.character)
        self.vispart.CanCollide = false
        self.vispart.Anchored = true
    end
    
    self.vispart.CFrame = cf
    self.vispart.Size = size
end

function Shared.GetAngle(normal)
    return math.deg(math.acos(normal:Dot(Vector3.yAxis)))
end

function Shared:IsGrounded(dir)
    local params = Shared.GetMovementParams(self)
    local cf = CFrame.new(self.collider.Position) - Vector3.new(0, self.collider.Size.Y/2, 0)
    local size = Config.FEET_HB_SIZE
    
    -- Fixed: Using correct offset logic
    local offset = if Movement.Keys.Space > 0 then 0.05 else Config.FOOT_OFFSET_AMOUNT
    dir = dir or Vector3.new(0, -1 * self.collider.Size.Y - offset, 0)
    
    -- Fixed: workspace:Blockcast() doesn't exist - using Raycast instead
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {self.character, workspace.CurrentCamera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.RespectCanCollide = false
    
    local result = workspace:Raycast(cf.Position, dir, params)
    
    HandleVisualization(self, cf, size)
    
    if not result then
        return false
    end
    
    local steepness = Shared.GetAngle(result.Normal)
    local isSurfing = steepness >= Config.MIN_SLOPE_ANGLE and steepness <= Config.MAX_SLOPE_ANGLE
    
    if isSurfing then
        return false, true, result, steepness
    end
    
    return true, false, result
end

function Shared:RotateCharacter()
    local collider = self.collider
    local camera = workspace.CurrentCamera
    local rotationLook = collider.Position + camera.CoordinateFrame.lookVector
    collider.CFrame = CFrame.new(collider.Position, Vector3.new(rotationLook.x, collider.Position.y, rotationLook.z))
    collider.RotVelocity = Vector3.new()
end

function Shared:GetMovementDirection(groundNormal)
    local forward = self.Keys.W + -self.Keys.S
    local side = self.Keys.A + -self.Keys.D
    groundNormal = groundNormal or Vector3.new(0,1,0)
    
    if forward == 0 and side == 0 then
        self.states.input_vec = Vector3.zero
        return Vector3.zero
    else
        self.states.input_vec = Vector3.new(-side, 0, -forward).Unit
        local forwardMove = groundNormal:Cross(self.collider.CFrame.RightVector)
        local sideMove = groundNormal:Cross(forwardMove)
        return (forwardMove * forward + sideMove * side).Unit
    end
end

function Shared:GetMovementParams()
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {self.character, workspace.CurrentCamera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.RespectCanCollide = false
    params.CollisionGroup = "PlayerMovement"
    return params
end

function Shared:VectorMa(start, scale, direction)
    return Vector3.new(
        start.X + direction.X * scale,
        start.Y + direction.Y * scale,
        start.Z + direction.Z * scale
    )
end

-- Trace functions
local Trace = {}

local numBumps = 1
local maxClipPlanes = 5
local _planes = {}
local numToCoord = {"X", "Y", "Z"}

local function ClipVelocity(self, input, normal, output, overbounce)
    local newVelMod = Vec3Mod.new(output)
    Trace.ClipVelocity(self, input, normal, newVelMod, overbounce)
    return newVelMod:ToVector3()
end

function Trace:TraceBox(start, destination)
    local contactOffset = 0.1 -- idk what this is
    local longSide = math.sqrt(contactOffset * contactOffset + contactOffset * contactOffset)
    local direction = (destination - start).Unit
    local maxDistance = (start - destination).Magnitude + longSide
    
    local result = {
        startPos = start,
        endPos = destination,
        fraction = 1,
        startSolid = false,
        hitPart = nil,
        hitPoint = Vector3.zero,
        planeNormal = Vector3.zero,
        distance = 0
    }
    
    -- Use a raycast to simulate trace box
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {Movement.character, workspace.CurrentCamera}
    params.FilterType = Enum.RaycastFilterType.Exclude
    
    local hit = workspace:Raycast(start, direction * maxDistance, params)
    
    if hit then
        result.fraction = hit.Distance / maxDistance
        result.hitPart = hit.Instance
        result.hitPoint = hit.Position
        result.planeNormal = hit.Normal
        result.distance = hit.Distance
    end
    
    return result
end

function Trace:ClipVelocity(input, normal, output, overbounce)
    local angle = normal.Y
    local blocked = 0x00     -- Assume unblocked.
    
    if angle > 0 then -- If the plane that is blocking us has a positive z component, then assume it's a floor.
        blocked = blocked or 0x01
    end
    
    if angle == 0 then -- If the plane has no Z, it is vertical (wall/step)
        blocked = blocked or 0x02
    end
    
    -- Determine how far along plane to slide based on incoming direction.
    local backoff = input:Dot(normal) * overbounce
    
    -- iterate once to make sure we aren't still moving through the plane
    for i = 1, 3, 1 do
        local ci = numToCoord[i]
        local change = normal[ci] * backoff
        output[ci] = input[ci] - change
    end
    
    local adjust = output:ToVector3():Dot(normal)
    if adjust < 0 then
        local vec = output:ToVector3() - (normal * adjust)
        output.x = vec.X
        output.y = vec.Y
        output.z = vec.Z
    end
    
    -- Return blocking flags.
    return blocked
end

function Trace:Reflect(velocity, origin)
    local newVelocity = Vector3.zero
    local blocked = 0
    local numplanes = 1
    local originalVelocity = velocity
    local primalVelocity = velocity
    local allFraction = 0
    local timeLeft = self.dt
    
    for bumpcount = 1, numBumps, 1 do
        if velocity.Magnitude == 0 then
            break
        end
        
        -- Assume we can move all the way from the current origin to the end point.
        local endp = Shared.VectorMa(self, origin, timeLeft, velocity)
        local trace = Trace.TraceBox(self, origin, endp)
        allFraction = allFraction + trace.fraction
        
        if trace.fraction > 0 then
            -- actually covered some distance
            originalVelocity = velocity
            numplanes = 0
        end
        
        -- If we covered the entire distance, we are done and can return.
        if trace.fraction == 1 then
            break
        end -- moved the entire distance
        
        -- If the plane we hit has a high z component in the normal, then it's probably a floor
        if trace.planeNormal.Y > Config.MAX_SLOPE_ANGLE then
            blocked = blocked or 1
        end
        
        -- If the plane has a zero z component in the normal, then it's a step or wall
        if trace.planeNormal.Y == 0 then
            blocked = blocked or 2 -- step/wall
        end
        
        -- Reduce amount of m_flFrameTime left by total time left * fraction that we covered.
        timeLeft = timeLeft - timeLeft * trace.fraction
        
        -- Did we run out of planes to clip against
        if numplanes >= maxClipPlanes then
            -- this shouldn't really happen
            -- Stop our movement if so.
            velocity = Vector3.zero
            break
        end
        
        -- Set up next clipping plane
        _planes[numplanes] = trace.planeNormal
        numplanes = numplanes + 1
        
        -- modify original_velocity so it parallels all of the clip planes
        if numplanes == 2 then
            if _planes[1].Y > Config.MAX_SLOPE_ANGLE then
                return blocked
            else
                newVelocity = ClipVelocity(self, originalVelocity, _planes[1], newVelocity, 1)
            end
            velocity = newVelocity
            originalVelocity = newVelocity
        else
            local _i = 0
            for i = 1, numplanes-1, 1 do
                _i = i
                newVelocity = ClipVelocity(self, originalVelocity, _planes[i], newVelocity, 1)
                local _j = 0
                for j = 1, numplanes-1, 1 do
                    _j = j
                    if j ~= i and velocity:Dot(_planes[j]) < 0 then
                        break
                    end
                end
                if _j == numplanes then
                    break
                end
            end
            
            if _i ~= numplanes then
                -- Do nothing
            else
                if numplanes ~= 3 then
                    velocity = Vector3.zero
                    break
                end
                local dir = _planes[1]:Cross(_planes[2]).Unit
                local d = dir:Dot(velocity)
                velocity = dir * d
            end
        end
        
        local d = velocity:Dot(primalVelocity)
        if d <= 0 then
            velocity = Vector3.zero
            break
        end
    end
    
    if allFraction == 0 then
        velocity = Vector3.zero
    end
    
    return velocity, blocked
end

local function ApplyMoverVelocity(self, velocity)
    local vel = Vector2.new(velocity.X, velocity.Z)
    self.mover.PlaneVelocity = vel
    return vel
end

function Physics:ApplyGroundVelocity(groundNormal)
    local wishDir = Shared.GetMovementDirection(self, groundNormal)
    local wishSpeed = wishDir.Magnitude * Config.RUN_SPEED
    
    -- normal friction
    if self.states.air_friction <= 0 then
        Physics.ApplyFriction(self)
    else
        -- friction that is applied due to the player reaching max speed while bhopping
        local sub = Config.AIR_MAX_SPEED_FRIC_DEC * self.dt * 60
        local curr = self.states.air_friction
        local fric = curr - sub
        if fric < 0 then
            fric = curr + fric
        end
        Physics.ApplyFriction(self, math.max(1, fric/Config.FRICTION))
        self.states.air_friction = math.max(0, curr - sub)
    end
    
    Physics.ApplyGroundAcceleration(self, wishDir, wishSpeed)
    Collisions.CollideAndSlide(self, Vector3.new(self.mover.PlaneVelocity.X, 0, self.mover.PlaneVelocity.Y))
    
    -- calculate & apply slope movement
    if Shared.GetAngle(groundNormal) < 5 then
        return
    end
    
    local curVel = Vector3.new(self.mover.PlaneVelocity.X, self.collider.Velocity.Y, self.mover.PlaneVelocity.Y)
    local forVel = groundNormal:Cross(CFrame.Angles(0,math.rad(90),0).LookVector * curVel)
    local yVel = 0
    
    if forVel.Magnitude > 0 then
        yVel = forVel.Unit.Y * curVel.Magnitude
    end
    
    self.collider.Velocity = Vector3.new(curVel.X, yVel, curVel.Z)
end

function Physics:ApplyGroundAcceleration(wishDir, wishSpeed)
    local addSpeed
    local accelerationSpeed
    local currentSpeed
    local currentVelocity = Vector3.new(self.mover.PlaneVelocity.X, 0, self.mover.PlaneVelocity.Y)
    local newVelocity = currentVelocity
    
    -- get current/add speed
    currentSpeed = currentVelocity:Dot(wishDir)
    addSpeed = wishSpeed - currentSpeed
    
    -- if we're not adding speed, dont do anything
    if addSpeed <= 0 then return end
    
    -- get accelSpeed, cap at addSpeed
    accelerationSpeed = math.min(Config.GROUND_ACCEL * self.dt * wishSpeed, addSpeed)
    
    -- you can't change the properties of a Vector3, so we do x, y, z
    newVelocity = newVelocity + (accelerationSpeed * wishDir)
    newVelocity = Vector3.new(newVelocity.X, 0, newVelocity.Z)
    
    -- clamp magnitude (max speed)
    if newVelocity.Magnitude > Config.RUN_SPEED then
        newVelocity = newVelocity.Unit * math.min(newVelocity.Magnitude, Config.RUN_SPEED)
    end
    
    -- apply acceleration
    ApplyMoverVelocity(self, newVelocity)
end

function Physics:ApplyAirVelocity(normal)
    normal = normal or Vector3.new(0,1,0)
    local vel = Vector3.new(self.mover.PlaneVelocity.X, 0, self.mover.PlaneVelocity.Y)
    local wishDir = Shared.GetMovementDirection(self, normal)
    local wishSpeed = wishDir.Magnitude * Config.AIR_SPEED
    local currSpeed = vel.Magnitude
    
    -- initiate extra friction for max speed
    if currSpeed > Config.AIR_MAX_SPEED then
        self.states.air_friction = Config.AIR_MAX_SPEED_FRIC
    end
    
    -- apply extra friction if necessary
    if self.states.air_friction > 0 and not self.states.surfing then
        Physics.ApplyFriction(self, 0.01 * self.states.air_friction, false)
    end
    
    Physics.ApplyAirAcceleration(self, wishDir, wishSpeed)
    local refVel = Vector3.new(self.mover.PlaneVelocity.X, self.collider.Velocity.Y, self.mover.PlaneVelocity.Y)
    ApplyMoverVelocity(self, Trace.Reflect(self, refVel, self.collider.Position))
end

function Physics:ApplyAirAcceleration(wishDir, wishSpeed)
    local currentSpeed
    local addSpeed
    local accelerationSpeed
    local currentVelocity = Vector3.new(self.mover.PlaneVelocity.X, 0, self.mover.PlaneVelocity.Y)
    
    -- get current/add speed
    currentSpeed = currentVelocity:Dot(wishDir)
    addSpeed = wishSpeed - currentSpeed
    
    -- if we're not adding speed, dont do anything
    if addSpeed <= 0 then return end
    
    -- get accelSpeed, cap at addSpeed
    accelerationSpeed = math.min(Config.AIR_ACCEL * self.dt * wishSpeed, addSpeed)
    
    -- get new velocity
    local newVelocity = currentVelocity + accelerationSpeed * wishDir
    
    -- apply acceleration
    ApplyMoverVelocity(self, newVelocity)
end

function Physics:ApplyFriction(modifier, inAir)
    local vel
    if inAir then
        vel = self.collider.Velocity
    else
        vel = Vector3.new(self.mover.PlaneVelocity.X, 0, self.mover.PlaneVelocity.Y)
    end
    
    local speed = vel.Magnitude
    modifier = modifier or 1
    local drop = 0
    local fric = inAir and Config.AIR_FRICTION or Config.FRICTION
    local decel = Config.GROUND_DECCEL
    local newSpeed
    local control
    
    -- if we're not moving, don't apply friction
    if speed <= 0 then
        return vel
    end
    
    control = speed < decel and decel or speed
    drop = control * fric * self.dt * modifier
    
    if type(drop) ~= "number" then drop = drop.Magnitude end
    
    newSpeed = math.max(speed - drop, 0)
    if speed > 0 and newSpeed > 0 then
        newSpeed = newSpeed / speed
    end
    
    vel = vel * newSpeed
    ApplyMoverVelocity(self, vel)
end

local function Init()
    Movement.Keys = {W = 0, S = 0, D = 0, A = 0, Space = 0}
    Movement.player = game.Players.LocalPlayer
    Movement.character = Movement.player.Character or Movement.player.CharacterAdded:Wait()
    Movement.collider = Movement.character:WaitForChild("HumanoidRootPart")
    Movement.vispart = false
    Movement.vis_coll_parts = {}
    Movement.config = Config
    
    local mover = Instance.new("LinearVelocity", Movement.collider)
    local a0 = Instance.new("Attachment", Movement.collider)
    a0.Name = "MovementAttachment"
    mover.Attachment0 = a0
    mover.MaxForce = 10000000
    mover.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
    mover.PrimaryTangentAxis = Vector3.new(1,0,0)
    mover.SecondaryTangentAxis = Vector3.new(0,0,1)
    Movement.mover = mover
    
    Movement.states = {grounded = false, air_friction = 0, input_vec = Vector3.zero, surfing = false, jumping = false}
end

local function Gravity()
    local mod = Movement.config.GRAVITY * Movement.dt
    Movement.collider.AssemblyLinearVelocity = Vector3.new(
        Movement.collider.AssemblyLinearVelocity.X,
        Movement.collider.AssemblyLinearVelocity.Y - mod,
        Movement.collider.AssemblyLinearVelocity.Z
    )
end

local function Air()
    Physics.ApplyAirVelocity(Movement)
    local vel = Vector3.new(Movement.mover.PlaneVelocity.X, Movement.collider.AssemblyLinearVelocity.Y, Movement.mover.PlaneVelocity.Y)
    vel = Trace.Reflect(Movement, vel, Movement.collider.CFrame.Position)
    Movement.mover.PlaneVelocity = Vector2.new(vel.X, vel.Z)
    Movement.collider.AssemblyLinearVelocity = vel
end

local function Ground(groundNormal)
    Physics.ApplyGroundVelocity(Movement, groundNormal)
end

local function Jump()
    sounds[math.random(1, #sounds)]:Play()
    Movement.temp_jump_last = tick()
    Movement.states.jumping = true
    Movement.collider.AssemblyLinearVelocity = Vector3.new(
        Movement.collider.AssemblyLinearVelocity.X,
        Movement.config.JUMP_VELOCITY,
        Movement.collider.AssemblyLinearVelocity.Z
    )
end

local function ProcessMovement()
    local isGrounded, isSurfing, result = Shared.IsGrounded(Movement)
    Movement.states.grounded = isGrounded or false
    Movement.states.surfing = isSurfing or false
    
    if Movement.collider.AssemblyLinearVelocity.Y < 0 then
        Movement.states.jumping = false
    end
    
    Shared.RotateCharacter(Movement)
    
    if Movement.states.jumping or not Movement.states.grounded then
        local groundNormal = false
        if isSurfing then
            groundNormal = result and result.Normal
            if Movement.collider.Velocity.Y > 0 then
                --Physics.ApplyFriction(Movement, false, true)
            end
        end
        Air(groundNormal)
        Gravity()
    elseif Movement.Keys.Space > 0 then
        Jump()
        Air()
    else
        Ground(result and result.Normal)
    end
end

local function InputBegan(input, gp)
    if input.KeyCode and Movement.Keys[input.KeyCode.Name] then
        Movement.Keys[input.KeyCode.Name] = 1
    end
end

local function InputEnded(input, gp)
    if input.KeyCode and Movement.Keys[input.KeyCode.Name] then
        Movement.Keys[input.KeyCode.Name] = 0
    end
end

local function Update(dt)
    Movement.dt = dt
    ProcessMovement()
end

Init()
UserInputService.InputBegan:Connect(InputBegan)
UserInputService.InputEnded:Connect(InputEnded)
RunService.RenderStepped:Connect(Update)
