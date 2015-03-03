       module simParams_mod
       use constants_mod
       implicit none

       ! ************************* GRID *************************
       logical :: checkICs                  = .false.   ! Check initial conditions
       logical :: quickStart                = .true.    ! Don't export initial fields
       logical :: printGrid                 = .false.   ! Print grid to screen
       logical :: autoMatchBetas            = .true.    ! Auto match stretching at wall
       integer :: symmetryPlane             = 3         ! 1,2,3 = x,y,z (for symmetry probe)

       logical :: nonUniformGridFluid       = .false.    ! (T/F)
       logical :: nonUniformGridWall        = .false.    ! (T/F, F-> overrides wall thickness)
       logical :: overrideGeometryWarnings  = .false.

       ! ******************** PARALLELIZATION *******************
       ! Use the -fopenMP flag to parallelize the following:
       !     - myError.f90 (LnError3D,LnError3DUniform)
       !     - myDel.f90 (myDel) done
       !     - mySOR.f90 (Poisson loop)
       !     - vectorOps.f90 (interpO2,myCollocatedCross,myNodeAdvect,myNodeMagnitude)
       !     - myTriOperator.f90 (applyTriOperator)
       !     - myTriSolver.f90 (applyTriSolver)
       ! 
       !     - myExport.f90 (exporting results), needs improvements
       ! 
       !     - myIO.f90 not yet (even possible?)
       ! 
       ! * = The poisson loop is the only routine affected by
       !     useOpenMP.

       ! ************************ U-FIELD ***********************
       logical :: solveMomentum = .true.
       logical :: restartU = .false.
       integer,parameter :: solveUMethod = 1
       !                                   1 : Explicit Euler
       !                                   2 : Semi-Implicit 3D ADI (Douglas)

       integer :: advectiveUFormulation = 1
       !                                  1 : Donor-Cell (conservative form)
       !                                  2 : Advective form
       !                                  3 : Upwind (not yet implemented)
       !                                  4 : Hybrid (not yet implemented)

       real(dpn) :: lambdu = 0.5 ! Upwind blending parameter  ( 0 <= lambdu <= 1 )
       !                                                       pure         central
       !                                                      upwind       difference

       ! ************************ B-FIELD ***********************
       logical :: solveInduction = .true.
       logical :: restartB = .false.
       logical :: cleanB = .false.
       logical :: multiMaterials = .false.

       integer,parameter :: solveBMethod = 4
       !                                   1 : Low Rem (Poisson, assumes uniform properties)
       !                                   2 : Low Rem (Pseudo time step for uniform properties)
       !                                   3 : Low Rem (Pseudo time step)
       !                                   4 : Low Rem Constrained Transport (CT) Method
       !                                   5 : Constrained Transport (CT) Method
       !                                   6 : Full Induction Equation, Not sure how this is supposed 
       !                                       to be different from CT method if it is conservative..
       !                                   7 : Low Rem Semi-Implicit 3D ADI (Douglas) (good for highly insulating walls)

       ! ************************** MHD *************************
       logical :: solveCoupled = .true.

       ! ****************** BENCHMARK CASES  ********************
       ! ********** (OVERRIDES USER DEFINED SETUP) **************
       ! Setting benchmarkCase will define all parameters for the 
       ! simulation EXCEPT
       !      Number of cells in fluid domain (in griddata.f90)
       !      Number of cells in wall domain  (in griddata.f90)
       !      All other parameters in this file
       !      preDefined cases (this must be set along side benchmarkCase)
       ! Setting benchmarkCase will define
       !      Geometry,stretching factors,...,Re,Ha,Rem,...,dt,Nmax
       ! 
       ! If both benchmarkCase and preDefinedCase are defined as
       ! non-zero, then the simulation will stop and ask what you
       ! meant to do (not yet implemented).
       ! 

       integer,parameter :: benchmarkCase = 102
       ! 
       ! 0-99-series (verification cases against exact solutions)
       ! 
       !    0 : LDC          , Re=400,Ha=0  (symmetry) Ni=even
       !    1 : LDC          , Re=400,Ha=0  (symmetry) Ni=odd
       ! 
       !    2 : LDC          , Re=400,Ha=0  (refinement in symmetry plane) N=32
       !    3 : LDC          , Re=400,Ha=0  (refinement in symmetry plane) N=64
       !    4 : LDC          , Re=400,Ha=0  (refinement in symmetry plane) N=128
       !    5 : LDC          , Re=400,Ha=0  (refinement in symmetry plane) N=256
       ! 
       !    6 : Duct Flow    , Re=400,Ha=0  (refinement) N=32
       !    7 : Duct Flow    , Re=400,Ha=0  (refinement) N=64
       !    8 : Duct Flow    , Re=400,Ha=0  (refinement) N=128
       !    9 : Duct Flow    , Re=400,Ha=0  (refinement) N=256
       ! 
       !    50 : LDC         , Re=2000,Ha=0 - Onset of turbulent flow
       !    51 : LDC         , Re=3200,Ha=0 - Turbulent flow
       ! 
       ! 100-series (Lid driven cavity flows)
       ! 
       !    100 : LDC , Re=400  , Ha=0    , S=1    (Guj / stella) uniform
       !    101 : LDC , Re=1000 , Ha=0    , S=1    (Guj / stella) non-uniform
       ! 
       !    102 : LDC , Re=100  , Ha=10   , S=1    (sergey)
       !    103 : LDC , Re=1000 , Ha=100  , S=1    (sergey)
       !    104 : LDC , Re=1000 , Ha=1000 , S=1    (sergey) - instabilities
       ! 
       !    105 : LDC , Re=100  , Ha=10   , S=1     (sergey)
       !    106 : LDC , Re=100  , Ha=10   , S=100   (sergey)
       !    107 : LDC , Re=100  , Ha=10   , S=1000  (sergey)
       !    108 : LDC , Re=100  , Ha=10   , S=10^6  (sergey)
       ! 
       !    109 : LDC , Re=100  , Ha=10   , S=1     (Sergey and Peter)
       ! 
       ! 200-series (Duct flows)
       ! 
       !    200 : Duct Flow   , Re=100.0  , Ha=0   (test case)
       ! 
       !    210 : Duct Flow   , Re=15574.07   , Ha=2900    (case B2)
       ! 
       ! 300-series (Cylinder driven cavity flows)
       ! 
       !    100 : CDC , Re=400
       ! 
       ! In order to make new benchmarkCases, prepare the following
       !    - MOONS.f90 (Number of steps, time step etc.)
       !    - griddata.f90 (geometry,stretching factors,N cells)
       !    - initializeSigmaMu.f90 (ICs)
       ! 
       ! ****************** PRE-DEFINED CASES  ********************
       ! ********** (OVERRIDES USER DEFINED SETUP) **************
       ! Setting preDefinedCase will define
       !         Ufield ICs
       !         Ufield BCs
       !         Bfield ICs
       !         Bfield BCs
       ! 
       ! If both benchmarkCase and pre-defined cases are defined as
       ! non-zero, then the simulation will stop and ask what you
       ! meant to do.

       integer,parameter :: preDefinedU_ICs = 1
       !                                      0 : User-defined case (no override)
       !                                      1 : Rest (u,v,w = 0)
       !                                      2 : Parabolic Duct Flow (in x)
       !                                      3 : Vortex

       ! ----------------------------------------
       integer,parameter :: preDefinedU_BCs = 1
       !                                      0 : User-defined case (no override)
       !                                      1 : Lid Driven Cavity
       !                                      2 : No Slip Cavity
       !                                      3 : Duct Flow (in x)
       !                                      4 : Cylinder Driven Cavity Flow (tornado)
       ! Lid Driven Cavity parameters:
       integer,parameter :: drivenFace      = 4 ! (1,2,3,4,5,6) = (x_min,x_max,y_min,y_max,z_min,z_max)
       integer,parameter :: drivenDirection = 1 ! (1,2,3) = (x,y,z)
       integer,parameter :: drivenSign      = 1 ! (-1,1) = {(-x,-y,-z),(x,y,z)}
       ! Duct Flow parameters:
       integer,parameter :: ductDirection   = 1 ! (1,2,3) = (x,y,z)
       ! Cylinder Driven Cavity parameters:
       integer,parameter :: cylinderFace    = 1 ! (1,2,3,4,5,6) = (x_min,x_max,y_min,y_max,z_min,z_max)
       integer,parameter :: cylinderSign    = 1 ! (-1,1) = {clockwise from +, clockwise from -}
       ! ----------------------------------------

       integer,parameter :: preDefinedB_BCs = 1
       !                                      0 : User-defined case (no override)
       !                                      1 : Psuedo-vaccuum BCs (dBn/dn = 0, B_tangential = 0)
       !                                      2 : B = 0
       
       integer,parameter :: preDefinedB_ICs = 1
       !                                      0 : User-defined case (no override)
       !                                      1 : Uniform applied (set applied_B_dir)
       !                                      2 : Fringing Magnetic field
       !                                      3 : Fringing Magnetic field (consistent)

       integer,parameter :: applied_B_dir = 3
       !                                    0 : No applied field:      B0 = (0,0,0)
       !                                    1 : Uniform applied field: B0 = (1,0,0)
       !                                    2 : Uniform applied field: B0 = (0,1,0)
       !                                    3 : Uniform applied field: B0 = (0,0,1)

       ! Below are settings that do not override benchmarkCase

       integer,parameter :: preDefined_Sigma = 0 ! sigma* = sigma_wall/sigma_l
       !                                       0 : User-defined case (no override)
       !                                       1 : sigma* = 1 (uniform, conducting)
       !                                       2 : sigma* = 10^-2 (insulating, need small dt for B)
       !                                       3 : sigma* = 10^-3 (insulating, need small dt for B)
       !                                       4 : sigma* = 10^-6 (insulating, need small dt for B)
       !                                       5 : sigma* = 10^2 (conducting)
       !                                       6 : sigma* = 10^3 (conducting)
       !                                       7 : sigma* = 10^6 (conducting)

       integer,parameter :: preDefined_SigmaMu = 0
       !                                         0 : User-defined case (no override)
       !                                         1 : sigma = mu = 1

       ! More difficult parameters to have pre-defined cases for:
       integer,parameter :: preDefinedGeometry = 0
       !                                         0 : User-defined case (no override)
       !                                         1 : Square, hmin=-1/2, hmax = 1/2, tw = 0.0
       !                                         2 : Square, hmin=-1, hmax = 1, tw = 0.0
       !                                         3 : Square, hmin=-1/2, hmax = 1/2, tw = 0.1
       !                                         4 : Square, hmin=-1, hmax = 1, tw = 0.1
       !                                         5 : Duct, L=25, a=1/2, tw = 0.0
       !                                         6 : Duct, L=25, a=1, tw = 0.0
       !                                         7 : Duct, L=25, a=1/2, tw = 0.1
       !                                         8 : Duct, L=25, a=1, tw = 0.1



       ! ************************ EXPORT ************************
       integer :: nskip_exportRaw            = 100000 ! Raw solution for restart (very expensive)
       integer :: nskip_export               = 100000 ! Processed solution for visualization (very expensive)
       integer :: nskip_exportTransient      = 50     ! Probed data (cheap)
       integer :: nskip_exportErrors         = 100    ! Divergences / Residuals (expensive)
       integer :: nskip_print                = 10     ! Printed data (cheap)
       integer :: transientExportXYZ         = 1      ! Component to export (1,2,3) = (x,y,z)


       ! ************************ DEBUGGING *********************
       ! logical :: checkSourceTermsBTF = .false.
       ! logical :: checkInterpolations = .false. ! Maybe make a separate program for unit testing?
       ! logical :: calculateOmegaPsi = .false.
       ! logical :: outputAlternativeFormats = .true.

       end module