# AirFoil

Simple AirFoil simulation; originally made by Sleitnick (Crazyman32), modified By Widgeon, and ported to roblox-ts by InfinityDesign.

This module handles the aerodynamic physics of a single airfoil by constantly calculating the lift and drag forces that act upon the foil.

## Example

```typescript
import { RunService } from "@rbxts/services"
import { Airfoil } from "../Airfoil"

const wing = new AirFoil(part, massOfPlane)

RunService.Heartbeat.Connect(() => {
    wing.Update()
})

// NOTE: airFoil.Update() should be called every "Heartbeat" (RunService.Heartbeat)
```

## Fields
```typescript
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
```

## Methods
```typescript
airFoil.Update()
airFoil.Stop()
airFoil.GetLiftCoefficient(angleOfAttack)
airFoil.GetDragCoefficient(liftCoefficient)
```

## References:
[NASA.gov Modern Lift Equation](https://www.grc.nasa.gov/www/Wright/airplane/lifteq.html)

[NASA.gov Modern Drag Equation](https://www.grc.nasa.gov/www/Wright/airplane/drageq.html)

[NASA.gov Inclination Effects on Lift](https://www.grc.nasa.gov/www/Wright/airplane/incline.html)

["CM32 Modified Fin Module" Roblox model by Widgeon](https://www.roblox.com/library/892419359/CM32-Modified-Fin-Module)