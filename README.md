# pdp-panel
Front panel for QBUS backplane

This project provides a switch panel for DEC QBUS backplanes. 
It provides power control for a ATX (PC type) power supply and
generates required signals for QBUS boards.(BPOK,BDCOK...)
All switches are debounced. Halt switch is implemented as well
as RUN indicator.

It has a timer that provides the 60hz. line time clock generated
by dividing a "color burst" crystal down to 60Hz. LTC switch is also
provided.
