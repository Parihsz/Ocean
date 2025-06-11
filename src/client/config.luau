--!strict
local Types = require(script.Parent.types)

export type Wave = Types.Wave

local Config = {}

Config.GRAVITY = 9.81
Config.GLOBAL_TIME_SCALE = 1.2

Config.NEAR_RADIUS = 100
Config.MID_RADIUS = 400
Config.FAR_FLATTEN_START = 1000

Config.PER_WAVE_JITTER = 0.08
Config.NOISE_SCALE = 0.045
Config.NOISE_CONTRAST = 0.9
Config.NOISE_TIME_SCALE = 0.1

Config.LongSwells = {
	{
		amplitude = 6.8,
		wavelength = 48,
		direction = vector.create(1, 0, 0.3),
		steepness = 0.95,
		phase = 0.0,
	},
	{
		amplitude = 6.2,
		wavelength = 42,
		direction = vector.create(-0.8, 0, -0.5),
		steepness = 0.94,
		phase = 1.3,
	},
	{
		amplitude = 5.5,
		wavelength = 38,
		direction = vector.create(0.6, 0, -0.8),
		steepness = 0.92,
		phase = 2.1,
	},
} :: { Wave }

Config.MidRollers = {
	{
		amplitude = 4.5,
		wavelength = 22,
		direction = vector.create(0.5, 0, -1),
		steepness = 0.88,
		phase = 0.4,
	},
	{
		amplitude = 4.2,
		wavelength = 20,
		direction = vector.create(-1, 0, 0.7),
		steepness = 0.87,
		phase = 2.0,
	},
	{
		amplitude = 3.8,
		wavelength = 18,
		direction = vector.create(0.9, 0, -0.4),
		steepness = 0.85,
		phase = 1.2,
	},
	{
		amplitude = 3.0,
		wavelength = 16,
		direction = vector.create(-0.3, 0, -1),
		steepness = 0.82,
		phase = 3.1,
	},
} :: { Wave }

Config.NearChop = {
	{
		amplitude = 2.8,
		wavelength = 8.0,
		direction = vector.create(1, 0, 0.8),
		steepness = 0.82,
		phase = 0.7,
	},
	{
		amplitude = 2.6,
		wavelength = 7.5,
		direction = vector.create(-1, 0, 0.5),
		steepness = 0.81,
		phase = 1.6,
	},
	{
		amplitude = 2.4,
		wavelength = 7.0,
		direction = vector.create(0.7, 0, -1),
		steepness = 0.80,
		phase = 2.5,
	},
	{
		amplitude = 2.0,
		wavelength = 6.0,
		direction = vector.create(-0.5, 0, -1),
		steepness = 0.78,
		phase = 3.3,
	},
	{
		amplitude = 1.8,
		wavelength = 5.5,
		direction = vector.create(0.9, 0, 0.3),
		steepness = 0.76,
		phase = 0.9,
	},
	{
		amplitude = 1.5,
		wavelength = 4.5,
		direction = vector.create(-0.8, 0, -0.6),
		steepness = 0.72,
		phase = 2.8,
	},
	{
		amplitude = 1.2,
		wavelength = 3.8,
		direction = vector.create(0.4, 0, 0.9),
		steepness = 0.65,
		phase = 1.8,
	},
	{
		amplitude = 1.0,
		wavelength = 3.2,
		direction = vector.create(-0.7, 0, 0.7),
		steepness = 0.60,
		phase = 3.7,
	},
} :: { Wave }

return Config::Types.Config
