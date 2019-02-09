# Distributed-Algorithm course work

Our implementations is split into 6 different folders. 
The make file:
- Versions refers to the differnt message requests. Version 1 and 2 is always {:broadcast, 1000, 3000} and {:broadcast, 10_000_000, 3000} respectively. Version 3 is the interesting request of our own.

- Peers refers to the number of peers spawned in the system.

Within each implementation folder:
- "make runall" will run all 3 different version of the implementation locally.

- "make up" will run the version declared in the make file at the top in Docker environment.

- To change differnt versions ran in Docker environment, simply change the version count in the make file.


