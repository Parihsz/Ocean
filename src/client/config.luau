local Types = require(script.Parent.types)

export type Wave = Types.Wave

local Config = {}

Config.GRAVITY = 9.81
Config.GLOBAL_TIME_SCALE = 0.42

Config.NEAR_RADIUS = 100
Config.MID_RADIUS = 400
Config.FAR_FLATTEN_START = 1000

Config.PER_WAVE_JITTER = 0.08
Config.NOISE_SCALE = 0.045
Config.NOISE_CONTRAST = 0.9
Config.NOISE_TIME_SCALE = 0.03

Config.LongSwells = {
	{
		amplitude = 4.2,
		wavelength = 36,
		direction = vector.create(1, 0, 0.4),
		steepness = 0.92,
		phase = 0.0,
	},
	{
		amplitude = 3.9,
		wavelength = 32,
		direction = vector.create(-1, 0, -0.3),
		steepness = 0.92,
		phase = 1.1,
	},
} :: { Wave }

Config.MidRollers = {
	{
		amplitude = 3.0,
		wavelength = 18,
		direction = vector.create(0.4, 0, -1),
		steepness = 0.83,
		phase = 0.3,
	},
	{
		amplitude = 2.8,
		wavelength = 16,
		direction = vector.create(-0.9, 0, 1),
		steepness = 0.80,
		phase = 1.9,
	},
	{
		amplitude = 1.4,
		wavelength = 20,
		direction = vector.create(1, 0, -0.2),
		steepness = 0.75,
		phase = 0.8,
	},
} :: { Wave }

Config.NearChop = {
	{
		amplitude = 2.0,
		wavelength = 7.2,
		direction = vector.create(1, 0, 1),
		steepness = 0.78,
		phase = 0.6,
	},
	{
		amplitude = 1.9,
		wavelength = 6.6,
		direction = vector.create(-1, 0, 0.6),
		steepness = 0.78,
		phase = 1.4,
	},
	{
		amplitude = 1.7,
		wavelength = 6.0,
		direction = vector.create(0.6, 0, -1),
		steepness = 0.77,
		phase = 2.2,
	},
	{
		amplitude = 1.3,
		wavelength = 5.2,
		direction = vector.create(-0.6, 0, -1),
		steepness = 0.75,
		phase = 3.0,
	},
	{
		amplitude = 0.6,
		wavelength = 3.6,
		direction = vector.create(0.8, 0, 0.2),
		steepness = 0.60,
		phase = 1.1,
	},
	{
		amplitude = 0.5,
		wavelength = 3.0,
		direction = vector.create(-0.8, 0, -0.4),
		steepness = 0.55,
		phase = 2.7,
	},
} :: { Wave }

return Config
