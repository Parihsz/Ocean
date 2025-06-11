export type Wave = {
	amplitude: number,
	wavelength: number,
	direction: vector,
	steepness: number,
	phase: number?,
	kVector: vector?,
	directionUnit: vector?,
	angularFrequency: number?,
	phaseOffset: number?,
	timeJitter: number?,
}

export type Config = {
	LongSwells: { Wave },
	MidRollers: { Wave },
	NearChop: { Wave },
	NOISE_SCALE: number,
	NOISE_TIME_SCALE: number,
	NOISE_CONTRAST: number,
	MID_RADIUS: number,
	NEAR_RADIUS: number,
	FAR_FLATTEN_START: number,

	GRAVITY: number,
	PER_WAVE_JITTER: number,
	GLOBAL_TIME_SCALE: number,
}
return nil
