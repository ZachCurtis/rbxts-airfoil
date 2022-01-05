// Air Foil
// Crazyman32 Modified By Widgeon ported to TypeScript by InfinityDesign
// January 18, 2017

/**
 * References:
		https://www.grc.nasa.gov/www/Wright/airplane/lifteq.html
		https://www.grc.nasa.gov/www/Wright/airplane/drageq.html
		https://www.grc.nasa.gov/www/Wright/airplane/incline.html
	
	
	This module handles the aerodynamic physics of a single airfoil by
	constantly calculating the lift and drag forces that act upon the foil.
		
	
	EXAMPLE USE:
	
	    import { RunService } from "@rbxts/services"
		import { Airfoil } from "../Airfoil"

		const wing = new AirFoil(part, massOfPlane)
		
		RunService.Heartbeat.Connect(() => {
			wing.Update()
        })

	NOTE: airFoil.Update() should be called every "Heartbeat" (RunService.Heartbeat)

 */

    export class Airfoil {
        constructor(part: BasePart, airplaneMass: number, overrideMaxForceLift?: number, overrideMaxForceDrag?: number)
    
        public Part: BasePart
        public Area: number
        public FrontalArea: number
        public VectorForce: VectorForce
        public DragAtZero: number
        public DragEfficiency: number
        public MaxForceLift: number
        public MaxForceDrag: number
        public LiftCoMultiplier: number
        public AspectRatio: number
    
        /**
         * Update the airfoil (This should ideally be invoked during RunService.Heartbeat)
         * Heavily commented due to complex nature of operations.
         */
        public Update(): void
    
        /**
         * Simply sets the VectorForce's force to 0
         */
        public Stop(): void
    
        /**
         * Lift Coefficient:
         * @param angleOfAttack number The angle between the airfoil and the plane's velocity vector
         */
        public GetLiftCoefficient(angleOfAttack: number): number
    
        /**
         * Drag Coefficient:
         * @param cl number lift coefficient
    
         */
        public GetDragCoefficient(cl: number): number
    }
    