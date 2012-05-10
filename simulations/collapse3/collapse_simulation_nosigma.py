from hopf.simulation import Simulation

# Sphere integrator
s = Simulation()
s.load_initial_conditions('collapse3.mat')

# No regularization
s.sigma = 0.0
s.run_simulation(tmax=15, numpoints=75, sim='sphere')
s.post_process()
s.save_results('collapse3_sphere_sigma00_sim.mat')

# Runge-Kutta, no regularization
s.sigma = 0.0
s.run_simulation(tmax=15, numpoints=75, sim='rk4')
s.post_process()
s.save_results('collapse3_rk4_sigma00_sim.mat')
