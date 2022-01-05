-- Air Foil
-- Crazyman32 Modified By Widgeon
-- January 18, 2017

--[[

	References:
		https://www.grc.nasa.gov/www/Wright/airplane/lifteq.html
		https://www.grc.nasa.gov/www/Wright/airplane/drageq.html
		https://www.grc.nasa.gov/www/Wright/airplane/incline.html
	
	
	This module handles the aerodynamic physics of a single airfoil by
	constantly calculating the lift and drag forces that act upon the foil.
		
	
	EXAMPLE USE:
	
	
		local AirFoil = require(thisModule)
		
		local wing = AirFoil.new(part, massOfPlane)
		
		game:GetService("RunService").Heartbeat:Connect(function()
			wing:Update()
		end)
	
	
	Fields:
	
		airFoil.Part
		airFoil.Area
		airFoil.FrontalArea
		airFoil.VectorForce
		airFoil.DragAtZero
		airFoil.DragEfficiency
		airFoil.MaxForceLift
		airFoil.MaxForceDrag
		airFoil.LiftCoMultiplier
		airFoil.AspectRatio
	
	
	Methods:
		
		airFoil:Update()
		airFoil:Stop()
		airFoil:GetLiftCoefficient(angleOfAttack)
		airFoil:GetDragCoefficient(liftCoefficient)
		
	
	NOTE: airFoil:Update() should be called every "Heartbeat" (RunService.Heartbeat)
	
--]]



local AIR_DENSITY = 0.00238 --SLUGS/FT^3
local PI = math.pi
local DOT = Vector3.new().Dot

local NEAR_ZERO_VECT = Vector3.new(0, 0.001, 0)

local MAX_FORCE_LIFT = 50000
local MAX_FORCE_DRAG = 50000


-- Clamp a Vector3's magnitude if needed:  [Only clamps upper limit]
local function ClampMagnitude(v, mag)
	return (v.Magnitude > mag and (v.Unit * mag) or v)
end



local AirFoil = {}
AirFoil.__index = AirFoil


-- Construct new airfoil:
	-- part: The foil
	-- airplaneMass: The overall mass of the airplane
function AirFoil.new(part: BasePart, airplaneMass: number, overrideMaxForceLift: number?, overrideMaxForceDrag: number?)
	assert(airplaneMass, "Mass must be set")
	
	local attachment = Instance.new("Attachment")	
	local vector_force = Instance.new("VectorForce")
	vector_force.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	vector_force.Attachment0 = attachment

	attachment.Parent = part
	vector_force.Parent = part
	
	local airfoil = setmetatable({
		Part = part;
		Area = part.Size.X * part.Size.Z;
		FrontalArea = part.Size.X * part.Size.Y;
		
		VectorForce = vector_force;		
		
		DragEfficiency = 1;
		MaxForceLift = (overrideMaxForceLift or MAX_FORCE_LIFT) * airplaneMass;
		MaxForceDrag = (overrideMaxForceDrag or MAX_FORCE_DRAG) * airplaneMass;
		LiftCoMultiplier = 1;
		AspectRatio = 0;
	}, AirFoil)
	-- Aspect ratio: (Chord^2 / WingArea)
	airfoil.AspectRatio = (part.Size.X * part.Size.X) / airfoil.Area
	return airfoil
end


-- Lift Coefficient:
function AirFoil:GetLiftCoefficient(angleOfAttack: number)
	-- I changed this function to represent a better AOA -> Cl dataset, based off a symetrical NACA0015 airfoil
	local x = math.clamp(math.abs(math.deg(angleOfAttack)),0,180)
	local cl = (-3.2320062123142157e-001 * math.pow(x,0)
        +  3.2063896852676865e-001 * math.pow(x,1)
        + -3.1111967496417550e-002 * math.pow(x,2)
        +  1.4450365259971250e-003 * math.pow(x,3)
        + -3.6528693615419203e-005 * math.pow(x,4)
        +  5.4080214922597435e-007 * math.pow(x,5)
        + -4.8339109713494433e-009 * math.pow(x,6)
        +  2.5672845996008519e-011 * math.pow(x,7)
        + -7.4538616584241532e-014 * math.pow(x,8)
	        +  9.1048463230283991e-017 * math.pow(x,9))
	return cl*math.sign(angleOfAttack)*self.LiftCoMultiplier
end

-- Drag Coefficient:
function AirFoil:GetDragCoefficient(cl: number)
	
	-- DragCoefficient = DragCoefficientAtZeroLift + LiftCoefficient^2 / (Pi * SurfaceAspectRatio * EfficiencyFactor)
	
	local e = self.DragEfficiency
	local ar = self.AspectRatio
	
	return (cl * cl) / (PI * ar * e)
	
end


-- Update the air foil (This should ideally be invoked during RunService.Heartbeat)
-- Heavily commented due to complex nature of operations.
function AirFoil:Update()
	local part = self.Part
	local v = part.Velocity+Vector3.new(0,0,0)--WIND

	if v.Magnitude <= 0.0001 then 
		v = NEAR_ZERO_VECT 
	end
	
	-- Airfoil's velocity relative to its rotation:
	local vLocal = part.CFrame:vectorToObjectSpace(v)
	
	-- Calculate angle of attack:
	local angleOfAttack = -math.atan2(vLocal.Y, -vLocal.Z)
	--self.AOA = angleOfAttack
	
	-- Get Lift and Drag Coefficients:
	local lc = self:GetLiftCoefficient(angleOfAttack)
	local dc = self:GetDragCoefficient(lc)
	--print("AOA:".. math.deg(angleOfAttack))
	
	-- Calculate the part of lift/drag equation that both equations share:
	local common = AIR_DENSITY * DOT(v, v)
	
	-- Calculate lift and drag force multipliers:
	local lift = common * self.Area * lc
	local drag = common * self.FrontalArea * dc
	
	-- Calculate lift and drag:
	local liftForce =( part.CFrame.upVector * lift)
	local dragForce = -v.Unit * drag
	
	-- print(self.Part.Name ..": Lift:"..liftForce.magnitude.." Drag:"..dragForce.magnitude)
		
	-- Clamp lift and drag magnitudes:
	liftForce = ClampMagnitude(liftForce, self.MaxForceLift)
	dragForce = ClampMagnitude(dragForce, self.MaxForceDrag)
	
	-- Apply lift and drag forces to the airfoil:
	local force = (liftForce + dragForce)
	self.VectorForce.Force = self.VectorForce.Force:Lerp(self.Part.CFrame:vectorToObjectSpace(force),0.8) --REDUCES FLUTTERING
end


-- Simply sets the VectorForce's force to 0
function AirFoil:Stop()
	self.VectorForce.Force = Vector3.new()
end


return {Airfoil = AirFoil}