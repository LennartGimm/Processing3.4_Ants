All variables in lines 3-19 can be changed. These do the following:

line	name				effect									Notes

3	number				controls how many ants spawn 						has an effect on fps but isn't major contributor, balance this with "gridDisplay"
4	v				fixed speed per ant. Every timestep ants will walk this many pixels 	reccomended to not go above 4 but instead opt in to increase simulation speed to avoid phasing. Use "showFrames" or "showFrames" instead
5	randomAngle			ants will turn randomly for some angle [-rA,+rA]			higher rA lead to more erratic behaviour and going above 0.5 can inhibit ants from forming paths
6	antSize				how large each ant is drant 						1 means point() is used, after that rect() is used
7	foodAmount			how much food spawns initially						if food is drawn (toggle this by commenting out showFood() in line 63) this can have an impact on fps
8	fov				what angle the ants can see						ants check 3 regions in front of them, one straight ahead and one for -fov and +fov respectively
9	viewDistance			controls how far away the three sample regions are from the and		The distance if measured from the ant to the centre of the region
10	fovSize				controls how big each sample region is					fovS < vD means ants will also sample behind them. fovSize denotes the radius of the region, not the diameter
11	pheromoneFade			how quickly pheromones evaoprate					ants leave pheromones of strength 1 or less. Each timestep all pheromones are multiplied by pF
12 	cavePheromoneCounterFalloff	how much less pheromones an ant leaves every step further from cave	when they follow another pheromone trail their own counter is slightly replenished
13	foodPheromoneCounterFalloff	same but when they come from food sources				they first leave pheromones strength 1, then fPCF, then fPCF^2, fPCF^3, etc
14	turningSpeed			how far ants turn towards the region with most pheromones		1.0 here is not in rad but how far compared to fov. Meaning if fov==0.1 and turningSpeed==0.5, the ant will turn by 0.05 each frame
15	gridDisplay			controls how many pixels the simulation shows				for gD==1 all pixels are drawn using point(). if gD>1 rect() is used instead and every rectangle has the size gD*gD
16	baseBrightness			how bright the background ist						[0,255] possible, has no impact on simulation other than the look
17	foodUsage			every time an ant picks up food, that source is reduced by this much	0.6 means 5 ants can pick up food befor a source is used up (threshold 0.1)
18 	showFrames			not every frame is drawn as that takes the longest time			sF==1 means all frames are shown. sF==4 means every 4th frame is shown, etc
19	skipFrames			how many timesteps are simulated before advancing one frame		does essentially the same as showFrames but enables going over 60fps


Note that all angles are in rad, so 2*pi = 360°
gridDisplay has not yet been properly implemented: The rectangles only sample the pixel in their centre instead of displaying an average over all points in their area

###############################################################################

These are the initial settings, copy them in if you have changed them and want to go back original values:

int number = 20000;
float v = 1;
float randomAngle = 0.1;
float antSize = 1;
float foodAmount = 2000;
float fov = 0.3;
float viewDistance = 8;
int fovSize = 2;
float pheromoneFade = 0.997;
float cavePheromoneCounterFalloff = 0.9965;
float foodPheromoneCounterFalloff = 0.998;
float turningSpeed = 0.3;
int gridDisplay = 5;
int baseBrightness = 30;
float foodUsage = 0.6;
int showFrames = 1;
int skipFrames = 1;