# Distributed-Algorithm Coursework

Our implementations is split into 6 different folders for each task.

Variables in the make file:
- `VERSION` refers to the different message requests. Version 1 and 2 is always `{ :broadcast, 1000, 3000 }` and `{ :broadcast, 10_000_000, 3000 }` respectively. Version 3 is the interesting request of our own.

- `PEERS` refers to the number of peers spawned in the system.

Commands:
- `make runall` will run all 3 version of the implementation locally.

- `make up` will run the version declared in the make file at the top in Docker environment.
