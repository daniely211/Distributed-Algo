# Distributed Algorithms Coursework

Our implementations is split into 6 different folders for each task.

### Broadcast1, Broadcast2, and Broadcast3
Variables in the make file:
- `VERSION` refers to the different message requests. Version 1 and 2 is always `{ :broadcast, max_broadcasts = 1000, timeout = 3000 }` and `{ :broadcast, max_broadcasts = 10_000_000, timeout = 3000 }` respectively. Version 3 is the interesting request of our own.

- `PEERS` refers to the number of peers spawned in the system.

Commands:
- `make runall` will run all 3 version of the implementation locally.

- `make up` will run the version declared in the make file at the top in Docker environment.

For Broadcast1, Broadcast2, and Broadcast3 the following applies:

### Broadcast4, Broadcast5, and Broadcast6

Variables in the Makefile:
