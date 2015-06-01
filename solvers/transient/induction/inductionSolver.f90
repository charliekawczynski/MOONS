       module inductionSolver_mod
       use simParams_mod
       use IO_tools_mod
       use IO_auxiliary_mod
       use IO_scalarFields_mod
       use IO_vectorFields_mod
       use myTime_mod
       use scalarField_mod
       use vectorField_mod

       use initializeBBCs_mod
       use initializeBfield_mod
       use initializeSigmaMu_mod
       use ops_embedExtract_mod

       use grid_mod
       use norms_mod
       use del_mod
       use ops_aux_mod
       use ops_interp_mod
       use ops_discrete_mod
       use ops_discrete_complex_mod
       use ops_physics_mod
       use BCs_mod
       use vectorBCs_mod
       use applyBCs_mod
       use solverSettings_mod
       use SOR_mod
       use ADI_mod
       use MG_mod
       use poisson_mod
       use probe_base_mod
       use probe_transient_mod

       implicit none

       private
       public :: induction,init,delete,solve

       public :: setDTime,setNmaxB,setRem,setHa,setNmaxCleanB

       public :: export,exportRaw,exportTransient
       public :: printExportBCs
       public :: addJCrossB
       public :: computeDivergence
       public :: computeCurrent
       public :: embedVelocity
       public :: computeMagneticEnergy
       public :: exportTransientFull

#ifdef _SINGLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(8)
#endif
#ifdef _DOUBLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(14)
#endif
#ifdef _QUAD_PRECISION_
       integer,parameter :: cp = selected_real_kind(32)
#endif

       real(cp),parameter :: zero = real(0.0,cp)
       real(cp),parameter :: one = real(1.0,cp)
       real(cp),parameter :: PI = 3.14159265358979

       type induction
         character(len=9) :: name = 'induction'
         ! --- Vector fields ---
         type(vectorField) :: B,Bstar,B0,B_face                ! CC data

         type(vectorField) :: J,J_cc,E                         ! Edge data

         type(vectorField) :: U_Ft                             ! Face data
         type(vectorField) :: U_cct                            ! Cell Center data
         type(vectorField) :: U_E,V_E,W_E                      ! Edge data

         type(vectorField) :: temp_E1,temp_E2                  ! Edge data
         type(vectorField) :: temp_F,temp_F2
         type(vectorField) :: temp_F3,temp_F4                  ! Edge data
         type(vectorField) :: temp_CC                          ! CC data

         type(vectorField) :: sigmaInv_edge,sigmaInv_face

         ! --- Scalar fields ---
         type(scalarField) :: sigma,mu          ! CC data
         type(scalarField) :: divB,divJ,phi,temp               ! CC data
         ! BCs:
         type(vectorBCs) :: B_bcs
         type(BCs) :: phi_bcs
         ! Solver settings
         type(solverSettings) :: ss_ind,ss_cleanB,ss_ADI
         ! Errors
         type(norms) :: err_divB,err_DivJ,err_ADI
         type(norms) :: err_cleanB,err_residual
         type(myTime) :: time_CP

         type(SORSolver) :: SOR_B, SOR_cleanB
         type(myADI) :: ADI_B
         type(multiGrid),dimension(2) :: MG ! For cleaning procedure

         type(indexProbe) :: probe_Bx,probe_By,probe_Bz
         type(indexProbe) :: probe_J
         type(errorProbe) :: probe_divB,probe_divJ
         type(probe) :: KB_energy,KB0_energy
         type(grid) :: g
         type(subdomain) :: SD

         integer :: nstep             ! Nth time step
         integer :: NmaxB             ! Maximum number iterations in solving B (if iterative)
         integer :: NmaxCleanB        ! Maximum number iterations to clean B
         real(cp) :: dTime            ! Time step
         real(cp) :: t                ! Time
         real(cp) :: Ha               ! Time
         real(cp) :: Rem              ! Magnetic Reynolds number
         real(cp) :: omega            ! Intensity of time changing magnetic field
       end type

       interface init;                 module procedure initInduction;                 end interface
       interface delete;               module procedure deleteInduction;               end interface
       interface solve;                module procedure inductionSolver;               end interface
       interface printExportBCs;       module procedure printExportInductionBCs;       end interface
       interface export;               module procedure inductionExport;               end interface
       interface exportRaw;            module procedure inductionExportRaw;            end interface
       interface exportTransient;      module procedure inductionExportTransient;      end interface
       interface exportTransientFull;  module procedure inductionExportTransientFull;  end interface
       interface computeDivergence;    module procedure computeDivergenceInduction;    end interface

       interface setDTime;             module procedure setDTimeInduction;             end interface

       contains

       ! ******************* INIT/DELETE ***********************

       subroutine initInduction(ind,g,SD,dir)
         implicit none
         type(induction),intent(inout) :: ind
         type(grid),intent(in) :: g
         type(subdomain),intent(in) :: SD
         character(len=*),intent(in) :: dir
         integer :: Nx,Ny,Nz
         write(*,*) 'Initializing induction:'

         ind%g = g
         ind%SD = SD
         ! --- Vector Fields ---
         Nx = g%c(1)%sc; Ny = g%c(2)%sc; Nz = g%c(3)%sc

         ! CC Data
         call allocateVectorField(ind%B,Nx,Ny,Nz)
         call allocateVectorField(ind%Bstar,ind%B)
         call allocateVectorField(ind%B0,ind%B)
         call allocateVectorField(ind%J_cc,ind%B)
         call allocateVectorField(ind%U_cct,ind%B)
         call allocateVectorField(ind%temp_CC,ind%B)

         ! Edge Data
         call allocateX(ind%J,g%c(1)%sc,g%c(2)%sn,g%c(3)%sn)
         call allocateY(ind%J,g%c(1)%sn,g%c(2)%sc,g%c(3)%sn)
         call allocateZ(ind%J,g%c(1)%sn,g%c(2)%sn,g%c(3)%sc)

         call allocateVectorField(ind%E,ind%J)
         call allocateVectorField(ind%U_E,ind%J)
         call allocateVectorField(ind%V_E,ind%J)
         call allocateVectorField(ind%W_E,ind%J)
         call allocateVectorField(ind%temp_E1,ind%J)
         call allocateVectorField(ind%temp_E2,ind%J)
         call allocateVectorField(ind%sigmaInv_edge,ind%J)

         ! Face Data
         call allocateX(ind%U_Ft,g%c(1)%sn,g%c(2)%sc,g%c(3)%sc)
         call allocateY(ind%U_Ft,g%c(1)%sc,g%c(2)%sn,g%c(3)%sc)
         call allocateZ(ind%U_Ft,g%c(1)%sc,g%c(2)%sc,g%c(3)%sn)

         call allocateVectorField(ind%temp_F,ind%U_Ft)
         call allocateVectorField(ind%sigmaInv_face,ind%U_Ft)
         call allocateVectorField(ind%temp_F2,ind%U_Ft)
         call allocateVectorField(ind%temp_F3,ind%U_Ft)
         call allocateVectorField(ind%temp_F4,ind%U_Ft)
         call allocateVectorField(ind%B_face,ind%U_Ft)

         ! --- Scalar Fields ---
         Nx = g%c(1)%sc; Ny = g%c(2)%sc; Nz = g%c(3)%sc

         call allocateField(ind%sigma,Nx,Ny,Nz)
         call allocateField(ind%mu,ind%sigma)
         call allocateField(ind%phi,ind%sigma)
         call allocateField(ind%temp,ind%sigma)

         call allocateField(ind%divB,ind%sigma)
         call allocateField(ind%divJ,ind%sigma)
         write(*,*) '     Fields allocated'


         ! --- Initialize Fields ---
         call initBBCs(ind%B_bcs,ind%phi_bcs,ind%B,g,cleanB)
         write(*,*) '     BCs initialized'

         call initBfield(ind%B,ind%B0,g,dir)
         write(*,*) '     B-field initialized'

         call applyAllBCs(ind%B,ind%B_bcs,g)
         write(*,*) '     BCs applied'

         call initSigmaMu(ind%sigma%phi,ind%mu%phi,ind%SD,g)
         call divide(one,ind%sigma)
         call cellCenter2Edge(ind%sigmaInv_edge,ind%sigma%phi,g)
         call cellCenter2Face(ind%sigmaInv_face,ind%sigma%phi,g)
         call initSigmaMu(ind%sigma%phi,ind%mu%phi,ind%SD,g)

         write(*,*) '     Materials initialized'

         call init(ind%probe_Bx,dir//'Bfield/','transient_Bx',&
         .not.restartB,shape(ind%B%x),(shape(ind%B%x)+1)/2,g)

         call init(ind%probe_By,dir//'Bfield/','transient_By',&
         .not.restartB,shape(ind%B%y),(shape(ind%B%y)+1)/2,g)

         call init(ind%probe_Bz,dir//'Bfield/','transient_Bz',&
         .not.restartB,shape(ind%B%z),(shape(ind%B%z)+1)/2,g)

         call init(ind%probe_J,dir//'Jfield/','transient_Jx',&
         .not.restartB,shape(ind%J_cc%x),(shape(ind%J_cc%x)+1)*2/3,g)

         call init(ind%probe_divB,dir//'Bfield/','transient_divB',.not.restartB)
         call init(ind%probe_divJ,dir//'Jfield/','transient_divJ',.not.restartB)

         call export(ind%probe_Bx)
         call export(ind%probe_By)
         call export(ind%probe_Bz)
         call export(ind%probe_J)
         call export(ind%probe_divB)
         call export(ind%probe_divJ)
         call init(ind%KB_energy,dir//'Bfield\','KB',.not.restartB)
         call init(ind%KB0_energy,dir//'Bfield\','KB0',.not.restartB)
         write(*,*) '     B/J probes initialized'

         call init(ind%err_divB)
         call init(ind%err_DivJ)
         call init(ind%err_cleanB)
         call init(ind%err_residual)

         ! Initialize solver settings
         call init(ind%ss_ind)
         call setName(ind%ss_ind,'SS B equation       ')
         call setMaxIterations(ind%ss_ind,ind%NmaxB)
         write(*,*) '     Solver settings for B initialized'

         ! ********** SET CLEANING PROCEDURE SOLVER SETTINGS *************
         call init(ind%ss_cleanB)
         call setName(ind%ss_cleanB,'cleaning B          ')
         call setMaxIterations(ind%ss_cleanB,ind%NmaxCleanB)
         write(*,*) '     Solver settings for cleaning initialized'

         ! Initialize multigrid
         ! if (cleanB) call init(ind%MG,ind%phi%s,ind%phi_bcs,ind%g,ind%ss_cleanB,.false.)

         if (restartB) then
         call readLastStepFromFile(ind%nstep,dir//'parameters/','n_ind')
         else; ind%nstep = 0
         endif
         ind%t = real(0.0,cp)
         ind%omega = real(1.0,cp)
         write(*,*) '     Finished'
       end subroutine

       subroutine deleteInduction(ind)
         implicit none
         type(induction),intent(inout) :: ind
         call delete(ind%B)
         call delete(ind%Bstar)
         call delete(ind%B0)

         call delete(ind%U_cct)
         call delete(ind%U_Ft)
         call delete(ind%U_E)
         call delete(ind%V_E)
         call delete(ind%W_E)

         call delete(ind%J)
         call delete(ind%J_cc)
         call delete(ind%E)

         call delete(ind%temp_CC)
         call delete(ind%temp_E1)
         call delete(ind%temp_E2)
         call delete(ind%temp_F)
         call delete(ind%temp_F2)
         call delete(ind%temp_F3)
         call delete(ind%B_face)
         call delete(ind%temp)

         call delete(ind%sigmaInv_edge)
         call delete(ind%sigmaInv_face)
         
         call delete(ind%sigma)
         call delete(ind%mu)

         call delete(ind%divB)
         call delete(ind%divJ)

         call delete(ind%phi)

         call delete(ind%B_bcs)
         call delete(ind%phi_bcs)

         call delete(ind%probe_Bx)
         call delete(ind%probe_By)
         call delete(ind%probe_Bz)
         call delete(ind%probe_J)
         call delete(ind%probe_divB)
         call delete(ind%probe_divJ)
         call delete(ind%g)

         ! call delete(ind%SOR_B)
         if (cleanB) call delete(ind%MG)

         write(*,*) 'Induction object deleted'
       end subroutine

       subroutine setDTimeInduction(ind,dt)
         implicit none
         type(induction),intent(inout) :: ind
         real(cp),intent(in) :: dt
         ind%dTime = dt
       end subroutine

       subroutine setNmaxB(ind,NmaxB)
         implicit none
         type(induction),intent(inout) :: ind
         integer,intent(in) :: NmaxB
         ind%NmaxB = NmaxB
       end subroutine

       subroutine setRem(ind,Rem)
         implicit none
         type(induction),intent(inout) :: ind
         real(cp),intent(in) :: Rem
         ind%Rem = Rem
       end subroutine

       subroutine setHa(ind,Ha)
         implicit none
         type(induction),intent(inout) :: ind
         real(cp),intent(in) :: Ha
         ind%Ha = Ha
       end subroutine

       subroutine setNmaxCleanB(ind,NmaxCleanB)
         implicit none
         type(induction),intent(inout) :: ind
         integer,intent(in) :: NmaxCleanB
         ind%NmaxCleanB = NmaxCleanB
       end subroutine

       ! ******************* EXPORT ****************************

       subroutine printExportInductionBCs(ind,dir)
         implicit none
         type(induction),intent(in) :: ind
         character(len=*),intent(in) :: dir
         if (solveInduction) call printVectorBCs(ind%B_bcs,'Bx','By','Bz')
         if (cleanB)         call printAllBoundaries(ind%phi_bcs,'phi')
         if (solveInduction) call writeVectorBCs(ind%B_bcs,dir//'parameters/','Bx','By','Bz')
         if (cleanB)         call writeAllBoundaries(ind%phi_bcs,dir//'parameters/','phi')
       end subroutine

       subroutine inductionExportTransient(ind,ss_MHD)
         implicit none
         type(induction),intent(inout) :: ind
         type(solverSettings),intent(in) :: ss_MHD
         if ((getExportTransient(ss_MHD))) then
           call apply(ind%probe_Bx,ind%nstep,ind%B%x)
           call apply(ind%probe_By,ind%nstep,ind%B%y)
           call apply(ind%probe_Bz,ind%nstep,ind%B%z)
           call apply(ind%probe_J,ind%nstep,ind%J_cc%x)
         endif

         if (getExportErrors(ss_MHD)) then
           call apply(ind%probe_divB,ind%nstep,ind%divB%phi)
           call apply(ind%probe_divJ,ind%nstep,ind%divJ%phi)
         endif
       end subroutine

       subroutine inductionExportRaw(ind,g,dir)
         implicit none
         type(induction),intent(in) :: ind
         type(grid),intent(in) :: g
         character(len=*),intent(in) :: dir
         if (restartB.and.(.not.solveInduction)) then
           ! This preserves the initial data
         else
           if (solveInduction) then
             write(*,*) 'Exporting RAW Solutions for B'
             call writeToFile(g,ind%B0,dir//'Bfield/','B0xct','B0yct','B0zct')
             call writeToFile(g,ind%B,dir//'Bfield/','Bxct','Byct','Bzct')
             call writeToFile(g,ind%J_cc,dir//'Jfield/','jxct','jyct','jzct')
             call writeToFile(g,ind%sigma%phi,dir//'material/','sigmac')
             call writeToFile(g,ind%divB%phi,dir//'Bfield/','divBct')
             call writeToFile(g,ind%divJ%phi,dir//'Jfield/','divJct')
             if (cleanB) call writeToFile(g,ind%phi%phi,dir//'Bfield/','phi')
             write(*,*) '     finished'
           endif
         endif
       end subroutine

       subroutine inductionExport(ind,g,dir)
         implicit none
         type(induction),intent(in) :: ind
         type(grid),intent(in) :: g
         character(len=*),intent(in) :: dir
         ! Locals
         integer :: Nx,Ny,Nz
         ! Interior
         real(cp),dimension(:,:,:),allocatable :: tempn,tempcc
         type(vectorField) :: tempVFn

         ! -------------------------- B/J FIELD AT NODES --------------------------
         if (solveInduction) then
           write(*,*) 'Exporting PROCESSED solutions for B'
           Nx = g%c(1)%sn; Ny = g%c(2)%sn; Nz = g%c(3)%sn
           call allocateVectorField(tempVFn,Nx,Ny,Nz)

           call cellCenter2Node(tempVFn,ind%B,g)
           call writeVecPhysical(g,tempVFn,dir//'Bfield/','Bxnt_phys','Bynt_phys','Bznt_phys')

           call cellCenter2Node(tempVFn,ind%B0,g)
           call writeVecPhysical(g,tempVFn,dir//'Bfield/','B0xnt_phys','B0ynt_phys','B0znt_phys')

           call cellCenter2Node(tempVFn,ind%J_cc,g)
           call writeVecPhysical(g,tempVFn,dir//'Jfield/','jxnt_phys','jynt_phys','jznt_phys')

         ! ----------------------- SIGMA/MU FIELD AT NODES ------------------------
           Nx = g%c(1)%sn; Ny = g%c(2)%sn; Nz = g%c(3)%sn
           allocate(tempn(Nx,Ny,Nz))
           call cellCenter2Node(tempn,ind%sigma%phi,g)
           call writeToFile(g,tempn,dir//'material/','sigman')
           ! call cellCenter2Node(tempn,ind%mu%phi,g)
           ! call writeToFile(g,tempn,dir//'material/','mun')
           deallocate(tempn)

         ! -------------------------- TOTAL DOMAIN VELOCITY -----------------------
           call writeToFile(g,ind%U_cct,dir//'Ufield/','uct','vct','wct')
           Nx = g%c(1)%sc; Ny = g%c(2)%sc; Nz = g%c(3)%sc
           allocate(tempcc(Nx,Ny,Nz))
           call div(tempcc,ind%U_cct%x,ind%U_cct%y,ind%U_cct%z,g)
           call writeToFile(g,tempcc,dir//'Ufield/','divUct')
           deallocate(tempcc)
           call delete(tempVFn)
           write(*,*) '     finished'
         endif
       end subroutine

       subroutine inductionExportTransientFull(ind,g,dir)
         implicit none
         type(induction),intent(inout) :: ind
         type(grid),intent(in) :: g
         character(len=*),intent(in) :: dir
         integer :: Nx,Ny,Nz
         type(vectorField) :: tempVFn

         ! -------------------------- B/J FIELD AT NODES --------------------------
         if (solveInduction) then
           Nx = g%c(1)%sn; Ny = g%c(2)%sn; Nz = g%c(3)%sn
           call allocateVectorField(tempVFn,Nx,Ny,Nz)

           call cellCenter2Node(tempVFn,ind%B,g)
           ! call writeVecPhysicalPlane(g,tempVFn,dir//'Bfield/transient/',&
           ! 'Bxnt_phys',&
           ! 'Bynt_phys',&
           ! 'Bznt_phys','_'//int2str(ind%nstep),1,2,ind%nstep)

           call writeScalarPhysicalPlane(g,tempVFn%x,dir//'Bfield/transient/',&
           'Bxnt_phys','_'//int2str(ind%nstep),1,2,ind%nstep)

           call cellCenter2Node(tempVFn,ind%J_cc,g)
           call writeVecPhysicalPlane(g,tempVFn,dir//'Jfield/transient/',&
            'jxnt_phys',&
            'jynt_phys',&
            'jznt_phys','_'//int2str(ind%nstep),1,2,ind%nstep)

           call delete(tempVFn)
         endif
       end subroutine

       ! ******************* SOLVER ****************************

       subroutine inductionSolver(ind,U,g_mom,g,ss_MHD,dir)
         implicit none
         ! ********************** INPUT / OUTPUT ************************
         type(induction),intent(inout) :: ind
         type(vectorField),intent(in) :: U
         type(grid),intent(in) :: g,g_mom
         type(solverSettings),intent(inout) :: ss_MHD
         character(len=*),intent(in) :: dir
         ! ********************** LOCAL VARIABLES ***********************
         ! ind%B0%x = real(exp(dble(-ind%omega*ind%t)),cp)
         ! ind%B0%y = real(exp(dble(-ind%omega*ind%t)),cp)
         ! ind%B0%z = real(1.0,cp)

         ! ind%B0%x = real(exp(dble(-ind%omega*ind%t)),cp)
         ! call perturb(ind%B0%x,g)
         ! ind%B0%y = real(0.0,cp)
         ! ind%B0%z = real(0.0,cp)

         ! ind%B0%x = real(0.0,cp)
         ! ind%B0%y = real(0.0,cp)
         ! ind%B0%z = exp(-ind%omega*ind%t)

         call embedVelocity(ind,U,g_mom)

         select case (solveBMethod)
         case (1); call lowRemPoisson(ind,ind%U_cct,g,ss_MHD)
         case (2); call lowRemPseudoTimeStepUniform(ind,ind%U_cct,g)
         case (3); call lowRemPseudoTimeStep(ind,ind%U_cct,g)
         case (4); call lowRemCTmethod(ind,g)
         case (5); call finiteRemCTmethod(ind,g)
         case (6); call LowRem_semi_implicit_ADI(ind,ind%U_cct,g,ss_MHD)
         case (7); call lowRemMultigrid(ind,ind%U_cct,g,ss_MHD)
         case (8); call lowRem_JacksExperiment(ind,ind%U_cct,g)
         end select
         if (cleanB) then
           call cleanBSolution(ind,g,ss_MHD)
           ! call cleanBMultigrid(ind,g,ss_MHD)
         endif
         ind%nstep = ind%nstep + 1
         ind%t = ind%t + ind%dTime ! This only makes sense for finite Rem

         if (getPrintParams(ss_MHD)) then
           call printPhysicalMinMax(ind%B,'Bx','By','Bz')
           call printPhysicalMinMax(ind%B0,'B0x','B0y','B0z')
           call printPhysicalMinMax(ind%divB%phi,ind%divB%s,'divB')
           call printPhysicalMinMax(ind%divJ%phi,ind%divJ%s,'divJ')
         endif
         call exportTransient(ind,ss_MHD)
         if (getExportErrors(ss_MHD)) then
           call computeDivergence(ind,ind%g)
           ! call exportTransientFull(ind,ind%g,dir)
         endif
         call computeCurrent(ind%J_cc,ind%B,ind%B0,ind%mu,ind%g)
         call computeMagneticEnergy(ind,ind%B,ind%B0,g_mom,ss_MHD)
       end subroutine

       subroutine lowRemPoissonOld(ind,U,g,ss_MHD)
         implicit none
         type(induction),intent(inout) :: ind
         type(vectorField),intent(in) :: U
         type(grid),intent(in) :: g
         type(solverSettings),intent(inout) :: ss_MHD
         call CCBfieldAdvect(ind%temp_CC,U,ind%B0,g)

         call poisson(ind%SOR_B,ind%B%x,ind%temp_CC%x,ind%B_bcs%x,g,ind%ss_ind,&
         ind%err_residual,getExportErrors(ss_MHD))

         call poisson(ind%SOR_B,ind%B%y,ind%temp_CC%y,ind%B_bcs%y,g,ind%ss_ind,&
         ind%err_residual,getExportErrors(ss_MHD))

         call poisson(ind%SOR_B,ind%B%z,ind%temp_CC%z,ind%B_bcs%z,g,ind%ss_ind,&
         ind%err_residual,getExportErrors(ss_MHD))
       end subroutine

       subroutine lowRemPoisson(ind,U,g,ss_MHD)
         implicit none
         ! ********************** INPUT / OUTPUT ************************
         type(induction),intent(inout) :: ind
         type(vectorField),intent(in) :: U
         type(grid),intent(in) :: g
         type(solverSettings),intent(inout) :: ss_MHD

         call cellCenter2Face(ind%temp_F2,ind%B0,g)

         call faceCurlCross_F(ind%temp_F,ind%U_Ft,ind%temp_F2,ind%temp_E1,ind%temp_E2,g)

         call poisson(ind%SOR_B,ind%B_face%x,ind%temp_F%x,ind%B_bcs%x,g,ind%ss_ind,&
         ind%err_residual,getExportErrors(ss_MHD))

         call poisson(ind%SOR_B,ind%B_face%y,ind%temp_F%y,ind%B_bcs%y,g,ind%ss_ind,&
         ind%err_residual,getExportErrors(ss_MHD))

         call poisson(ind%SOR_B,ind%B_face%z,ind%temp_F%z,ind%B_bcs%z,g,ind%ss_ind,&
         ind%err_residual,getExportErrors(ss_MHD))

         call face2CellCenter(ind%B,ind%B_face,g)
       end subroutine

       subroutine lowRemPseudoTimeStepUniform(ind,U,g)
         ! This routine assumed div(B)=0 (which requires uniform properties), 
         ! which is how it differs from lowRemPseudoTimeStep(). This was an 
         ! important case to test against the Poisson solution, since the 
         ! terms are essentially the same, but a different iterative method 
         ! is applied.
         implicit none
         type(induction),intent(inout) :: ind
         type(vectorField),intent(in) :: U
         type(grid),intent(in) :: g
         integer :: i
         
         do i=1,ind%NmaxB
           call assign(ind%Bstar,zero)
           ! ------------- diffusion term -------------
           call lap(ind%temp_CC,ind%B,g)
           call multiply(ind%temp_CC,ind%dTime)
           call add(ind%Bstar,ind%temp_CC)
           
           ! ------------- source term -------------
           call CCBfieldAdvect(ind%temp_CC,U,ind%B0,g)
           call multiply(ind%temp_CC,ind%dTime)
           call subtract(ind%Bstar,ind%temp_CC)

           ! Add induced field of previous time step (B^n)
           call multiply(ind%B,ind%mu)
           call add(ind%B,ind%Bstar)

           ! Impose BCs:
           call applyAllBCs(ind%B,ind%B_bcs,g)
         enddo
       end subroutine

       subroutine lowRemPseudoTimeStep(ind,U,g)
         implicit none
         type(induction),intent(inout) :: ind
         type(vectorField),intent(in) :: U
         type(grid),intent(in) :: g
         integer :: i

         do i=1,ind%NmaxB
           call assign(ind%Bstar,zero)

           ! ------------- diffusion term -------------
           call divide(ind%B,ind%mu)
           call CCBfieldDiffuse(ind%temp_CC,ind%B,ind%sigmaInv_face,g)
           call multiply(ind%B,ind%mu)

           call multiply(ind%temp_CC,ind%dTime)
           call subtract(ind%Bstar,ind%temp_CC)
           
           ! ------------- source term -------------
           call CCBfieldAdvect(ind%temp_CC,U,ind%B0,g)
           call multiply(ind%temp_CC,ind%dTime)
           call subtract(ind%Bstar,ind%temp_CC)

           ! Add induced field of previous time step (B^n)
           call add(ind%B,ind%Bstar)

           ! Impose BCs:
           call applyAllBCs(ind%B,ind%B_bcs,g)
         enddo
       end subroutine

       subroutine lowRemCTmethodOld(ind,U,g)
         ! inductionSolverCT solves the induction equation using the
         ! Constrained Transport (CT) Method. The magnetic field is
         ! stored and collocated at the cell center. The magnetic
         ! field is updated using Faraday's Law, where the electric
         ! field is solved for using appropriate fluxes as described
         ! in "Tóth, G. The divergence Constraint in Shock-Capturing 
         ! MHD Codes. J. Comput. Phys. 161, 605–652 (2000)."
         ! The velocity field is assumed to be cell centered.
         implicit none
         type(induction),intent(inout) :: ind
         type(vectorField),intent(in) :: U
         type(grid),intent(in) :: g
         integer :: i

         do i=1,ind%NmaxB

           ! Compute current from appropriate fluxes:

           ! J = curl(B_face)_edge
           call cellCenter2Face(ind%temp_F,ind%B,g)
           call curl(ind%J,ind%temp_F,g)

           ! Compute fluxes of u cross B0
           call cross(ind%temp_CC,U,ind%B0)
           call cellCenter2Edge(ind%E,ind%temp_CC,g)

           ! E = j/sig - uxB
           ! ind%E = ind%J*ind%sigmaInv_edge - ind%E
           call multiply(ind%J,ind%sigmaInv_edge)
           call subtract(zero,ind%E)
           call add(ind%E,ind%J)

           ! F = curl(E_edge)_face
           call curl(ind%temp_F,ind%E,g)

           ! tempVF = interp(F)_face->cc
           call face2CellCenter(ind%temp_CC,ind%temp_F,g)

           ! Add induced field of previous time step (B^n)
           ! ind%B = ind%B - ind%dTime*ind%temp_CC
           call multiply(ind%temp_CC,ind%dTime)
           call subtract(ind%B,ind%temp_CC)

           ! Impose BCs:
           call applyAllBCs(ind%B,ind%B_bcs,g)
         enddo
       end subroutine

       subroutine lowRemCTmethod(ind,g)
         ! inductionSolverCT solves the induction equation using the
         ! Constrained Transport (CT) Method. The magnetic field is
         ! stored and collocated at the cell center. The magnetic
         ! field is updated using Faraday's Law, where the electric
         ! field is solved for using appropriate fluxes as described
         ! in "Tóth, G. The divergence Constraint in Shock-Capturing 
         ! MHD Codes. J. Comput. Phys. 161, 605–652 (2000)."
         ! The velocity field is assumed to be cell centered.
         implicit none
         type(induction),intent(inout) :: ind
         type(grid),intent(in) :: g
         integer :: i

         do i=1,ind%NmaxB

           ! Compute current from appropriate fluxes:

           ! J = curl(B_face)_edge
           call cellCenter2Face(ind%temp_F,ind%B,g)
           call curl(ind%J,ind%temp_F,g)

           ! Compute fluxes of u cross B0
           call edgeCrossCC_E(ind%E,ind%U_E,ind%V_E,ind%W_E,ind%B0,g)

           ! E = j/sig - uxB
           ! ind%E = ind%J*ind%sigmaInv_edge - ind%E
           call multiply(ind%J,ind%sigmaInv_edge)
           call subtract(zero,ind%E)
           call add(ind%E,ind%J)

           ! F = curl(E_edge)_face
           call curl(ind%temp_F,ind%E,g)

           ! tempVF = interp(F)_face->cc
           call face2CellCenter(ind%temp_CC,ind%temp_F,g)

           ! Add induced field of previous time step (B^n)
           ! ind%B = ind%B - ind%dTime*ind%temp_CC
           call multiply(ind%temp_CC,ind%dTime)
           call subtract(ind%B,ind%temp_CC)

           ! Impose BCs:
           call applyAllBCs(ind%B,ind%B_bcs,g)
         enddo
       end subroutine

       subroutine lowRem_JacksExperiment(ind,U,g)
         implicit none
         type(induction),intent(inout) :: ind
         type(vectorField),intent(in) :: U
         type(grid),intent(in) :: g
         integer :: i,t,b
         b = 10
         t = 21

         do i=1,ind%NmaxB

           ! Compute current from appropriate fluxes:

           ! J = curl(B_face)_edge
           call cellCenter2Face(ind%temp_F,ind%B,g)
           call curl(ind%J,ind%temp_F,g)

           ind%J%y(:,1:2,b) = real(1.0,cp)
           ind%J%y(:,1:2,t) = real(-1.0,cp)

           ind%J%y(:,ind%J%sy(2)-1:ind%J%sy(2),b) = real(1.0,cp)
           ind%J%y(:,ind%J%sy(2)-1:ind%J%sy(2),t) = real(-1.0,cp)

           ! Compute fluxes of u cross B0
           call cross(ind%temp_CC,U,ind%B0)
           call cellCenter2Edge(ind%E,ind%temp_CC,g)

           ! E = j/sig - uxB
           ! ind%E = ind%J*ind%sigmaInv_edge - ind%E
           call multiply(ind%J,ind%sigmaInv_edge)
           call subtract(zero,ind%E)
           call add(ind%E,ind%J)

           ! F = curl(E_edge)_face
           call curl(ind%temp_F,ind%E,g)

           ! tempVF = interp(F)_face->cc
           call face2CellCenter(ind%temp_CC,ind%temp_F,g)

           ! Add induced field of previous time step (B^n)
           ! ind%B = ind%B - ind%dTime*ind%temp_CC
           call multiply(ind%temp_CC,ind%dTime)
           call subtract(ind%B,ind%temp_CC)

           ! Impose BCs:
           call applyAllBCs(ind%B,ind%B_bcs,g)
         enddo
       end subroutine

       subroutine finiteRemCTmethod(ind,g)
         ! finiteRemCTmethod solves the induction equation using the
         ! Constrained Transport (CT) Method. The magnetic field is
         ! stored and collocated at the cell center. The magnetic
         ! field is updated using Faraday's Law, where the electric
         ! field is solved for using appropriate fluxes as described
         ! in "Tóth, G. The divergence Constraint in Shock-Capturing 
         ! MHD Codes. J. Comput. Phys. 161, 605–652 (2000)."
         ! The velocity field is assumed to be cell centered.
         implicit none
         ! ********************** INPUT / OUTPUT ************************
         type(induction),intent(inout) :: ind
         type(grid),intent(in) :: g
         real(cp) :: eps,k

         ! Compute current from appropriate fluxes:
         ! Assumes curl(B0) = 0 (so B is not added to this)
         ! J = curl(B_face)_edge
         call cellCenter2Face(ind%temp_F,ind%B,g)
         call curl(ind%J,ind%temp_F,g)

         ! Compute fluxes of u cross (B-B0)
         call add(ind%B,ind%B0)
         ! call cross(ind%Bstar,ind%U_cct,ind%B)
         ! call cellCenter2Edge(ind%E,ind%Bstar,g)
         call edgeCrossCC_E(ind%E,ind%U_E,ind%V_E,ind%W_E,ind%B,g)
         call subtract(ind%B,ind%B0)

         ! E = 1/Rem*j/sig - uxB
         ! ind%E = ind%J*ind%sigmaInv_edge - ind%E
         call multiply(ind%J,ind%sigmaInv_edge)
         call divide(ind%J,ind%Rem)
         call subtract(zero,ind%E)
         call add(ind%E,ind%J)

         ! F = Curl(E_edge)_face
         call curl(ind%temp_F,ind%E,g)

         ! tempVF = interp(F)_face->cc
         call face2CellCenter(ind%temp_CC,ind%temp_F,g)

         ! Add induced field of previous time step (B^n)
         ! ind%B = ind%B - ind%dTime*ind%temp_CC
         call multiply(ind%temp_CC,ind%dTime)
         call subtract(ind%B,ind%temp_CC)

         ! Add time changing applied magnetic field
         ! ind%temp_CC%x = -ind%dTime*ind%omega*exp(dble(-ind%omega*ind%t))
         ! ind%temp_CC%y = -ind%dTime*ind%omega*exp(dble(-ind%omega*ind%t))
         ! ind%temp_CC%z = real(0.0,cp)

         ! ind%temp_CC%x = -ind%dTime*ind%omega*exp(dble(-ind%omega*ind%t))
         ind%temp_CC%x = -ind%dTime*ind%omega*exp(dble(-ind%omega*ind%t))
         call perturb(ind%temp_CC%x,ind%g)

         ! k = real(0.1,cp); eps = real(0.001,cp)
         ! ind%temp_CC%x = ind%temp_CC%x*(real(1.0,cp) + eps*sin(k*ind%t))
         ind%temp_CC%y = real(0.0,cp)
         ind%temp_CC%z = real(0.0,cp)
         call subtract(ind%B,ind%temp_CC)

         ! Impose BCs:
         call applyAllBCs(ind%B,ind%B_bcs,g)
       end subroutine

       subroutine LowRem_semi_implicit_ADI(ind,U,g,ss_MHD)
         ! inductionSolverCT solves the induction equation using the
         ! Constrained Transport (CT) Method. The magnetic field is
         ! stored and collocated at the cell center. The magnetic
         ! field is updated using Faraday's Law, where the electric
         ! field is solved for using appropriate fluxes as described
         ! in "Tóth, G. The divergence Constraint in Shock-Capturing 
         ! MHD Codes. J. Comput. Phys. 161, 605–652 (2000)."
         ! The velocity field is assumed to be cell centered.
         implicit none
         ! ********************** INPUT / OUTPUT ************************
         type(induction),intent(inout) :: ind
         type(vectorField),intent(in) :: U
         type(grid),intent(in) :: g
         type(solverSettings),intent(inout) :: ss_MHD

         ! J = curl(B_face)_edge
         call cellCenter2Face(ind%temp_F,ind%B,g)
         call curl(ind%J,ind%temp_F,g)

         ! Compute fluxes of u cross B0
         call cross(ind%temp_CC,U,ind%B0)
         call cellCenter2Edge(ind%E,ind%temp_CC,g)

         ! E = j/sig - uxB
         ! ind%E = ind%J*ind%sigmaInv_edge - ind%E
         call multiply(ind%J,ind%sigmaInv_edge)
         call subtract(zero,ind%E)
         call add(ind%E,ind%J)

         ! F = Curl(E)
         call curl(ind%temp_F,ind%E,g)

         ! tempVF = interp(F)_face->cc
         call face2CellCenter(ind%temp_CC,ind%temp_F,g)

         ! Subtract laplacian from B^n
         call lap(ind%Bstar,ind%B,ind%sigmaInv_face,g)

         ! ind%temp_CC = ind%temp_CC - ind%Bstar
         call subtract(ind%temp_CC,ind%Bstar)

         ! Solve with semi-implicit ADI
         call setDt(ind%ADI_B,ind%dTime)
         call setAlpha(ind%ADI_B,real(1.0,cp))

         call init(ind%ss_ADI)
         call setName(ind%ss_ADI,'ADI for B-field     ')

         call apply(ind%ADI_B,ind%B%x,ind%temp_CC%x,ind%B_bcs%x,g,&
            ind%ss_ADI,ind%err_ADI,getExportErrors(ss_MHD))
         call apply(ind%ADI_B,ind%B%y,ind%temp_CC%y,ind%B_bcs%y,g,&
            ind%ss_ADI,ind%err_ADI,getExportErrors(ss_MHD))
         call apply(ind%ADI_B,ind%B%z,ind%temp_CC%z,ind%B_bcs%z,g,&
            ind%ss_ADI,ind%err_ADI,getExportErrors(ss_MHD))

         ! Impose BCs:
         call applyAllBCs(ind%B,ind%B_bcs,g)
       end subroutine

       subroutine lowRemMultigrid(ind,U,g,ss_MHD)
         implicit none
         ! ********************** INPUT / OUTPUT ************************
         type(induction),intent(inout) :: ind
         type(vectorField),intent(in) :: U
         type(grid),intent(in) :: g
         type(solverSettings),intent(inout) :: ss_MHD
         type(multiGrid),dimension(2) :: MG

         call CCBfieldAdvect(ind%temp_CC,U,ind%B0,g)

         call poisson(MG,ind%B%x,ind%temp_CC%x,ind%B_bcs%x,g,ind%ss_ind,&
         ind%err_residual,.false.)

         call poisson(MG,ind%B%y,ind%temp_CC%y,ind%B_bcs%y,g,ind%ss_ind,&
         ind%err_residual,.false.)

         call poisson(MG,ind%B%z,ind%temp_CC%z,ind%B_bcs%z,g,ind%ss_ind,&
         ind%err_residual,.false.)
       end subroutine

       ! ******************* CLEANING **************************

       subroutine cleanBSolutionOld(ind,g,ss_MHD)
         implicit none
         type(induction),intent(inout) :: ind
         type(grid),intent(in) :: g
         type(solverSettings),intent(in) :: ss_MHD
         call div(ind%temp%phi,ind%B_face,g)

         call poisson(ind%SOR_cleanB,ind%phi%phi,ind%temp%phi,ind%phi_bcs,g,ind%ss_cleanB,&
          ind%err_cleanB,getExportErrors(ss_MHD))

         call grad(ind%Bstar,ind%phi%phi,g)
         call subtract(ind%B,ind%Bstar)

         ! Impose BCs:
         call applyAllBCs(ind%B,ind%B_bcs,g)
       end subroutine

       subroutine cleanBSolution(ind,g,ss_MHD)
         implicit none
         type(induction),intent(inout) :: ind
         type(grid),intent(in) :: g
         type(solverSettings),intent(in) :: ss_MHD
         call div(ind%temp%phi,ind%B_face,g)

         call poisson(ind%SOR_cleanB,ind%phi%phi,ind%temp%phi,ind%phi_bcs,g,ind%ss_cleanB,&
          ind%err_cleanB,getExportErrors(ss_MHD))

         call grad(ind%temp_F2,ind%phi%phi,g)
         call subtract(ind%B_face,ind%temp_F2)

         call face2CellCenter(ind%B,ind%B_face,g)
         ! Impose BCs:
         ! call applyAllBCs(ind%B,ind%B_bcs,g)
       end subroutine

       subroutine cleanBMultigrid(ind,g,ss_MHD)
         implicit none
         type(induction),intent(inout) :: ind
         type(grid),intent(in) :: g
         type(solverSettings),intent(in) :: ss_MHD

         call div(ind%temp%phi,ind%B,g)
         call poisson(ind%MG,ind%phi%phi,ind%temp%phi,ind%phi_bcs,g,ind%ss_cleanB,&
          ind%err_CleanB,getExportErrors(ss_MHD))

         call grad(ind%Bstar,ind%phi%phi,g)
         call subtract(ind%B,ind%Bstar)

         ! Impose BCs:
         call applyAllBCs(ind%B,ind%B_bcs,g)
       end subroutine

       ! ********************* COMPUTE *****************************

       subroutine addJCrossBOld(jcrossB,ind,g_mom,g_ind,Re,Ha)
         ! addJCrossB computes the ith component of Ha^2/Re j x B
         ! where j is the total current and B is the applied or total mangetic
         ! field, depending on the solveBMethod.
         implicit none
         type(vectorField),intent(inout) :: jcrossB
         type(induction),intent(inout) :: ind
         type(grid),intent(in) :: g_mom,g_ind
         real(cp),intent(in) :: Re,Ha
         type(vectorField) :: temp

         call allocateVectorField(temp,jcrossB)
         call assign(temp,jcrossB)

         select case (solveBMethod)
         case (5,6) ! Finite Rem

         call assign(ind%Bstar,ind%B0)
         call add(ind%Bstar,ind%B)
         call curl(ind%J_cc,ind%Bstar,g_ind)

         case default ! Low Rem

         call assign(ind%Bstar,ind%B)
         call curl(ind%J_cc,ind%Bstar,g_ind)
         call assign(ind%Bstar,ind%B0)

         end select

         call cross(ind%temp_CC,ind%J_cc,ind%Bstar)
         call cellCenter2Face(ind%temp_F,ind%temp_CC,g_ind)

         call extractFace(temp,ind%temp_F,ind%SD,g_mom,2)

         call multiply(temp,Ha**real(2.0,cp)/Re)
         call add(jcrossB,temp)
         call delete(temp)
       end subroutine

       subroutine addJCrossB(jcrossB,ind,g_mom,g_ind,Re,Ha)
         ! addJCrossB computes the ith component of Ha^2/Re j x B
         ! where j is the total current and B is the applied or total mangetic
         ! field, depending on the solveBMethod.
         implicit none
         type(vectorField),intent(inout) :: jcrossB
         type(induction),intent(inout) :: ind
         type(grid),intent(in) :: g_mom,g_ind
         real(cp),intent(in) :: Re,Ha

         select case (solveBMethod)
         case (5,6) ! Finite Rem

         call assign(ind%Bstar,ind%B0)
         call add(ind%Bstar,ind%B)
         call curl(ind%J_cc,ind%Bstar,g_ind)

         case default ! Low Rem

         call assign(ind%Bstar,ind%B)
         call curl(ind%J_cc,ind%Bstar,g_ind)
         call assign(ind%Bstar,ind%B0)

         end select

         call cross(ind%temp_CC,ind%J_cc,ind%Bstar)
         call cellCenter2Face(ind%temp_F,ind%temp_CC,g_ind)

         call extractFace(jcrossB,ind%temp_F,ind%SD,g_mom,2)

         call multiply(jcrossB,Ha**real(2.0,cp)/Re)
       end subroutine

       subroutine computeDivergenceInduction(ind,g)
         implicit none
         type(induction),intent(inout) :: ind
         type(grid),intent(in) :: g
         if (solveInduction) then
           select case (solveBMethod)
           case (4:5)
             ! CT method enforces div(b) = 0, (result is in CC), 
             ! when computed from FACE-centered data:
             call div(ind%divB%phi,ind%temp_F,g)
           case default
             call div(ind%divB%phi,ind%B,g)
           end select
         endif
         call div(ind%divJ%phi,ind%J_cc,g)
       end subroutine

       subroutine computeCurrent(J,B,B0,mu,g)
         implicit none
         type(vectorField),intent(inout) :: B,J
         type(vectorField),intent(in) :: B0
         type(scalarField),intent(in) :: mu
         type(grid),intent(in) :: g
         ! B = (B + B0)/mu
         call add(B,B0)
         ! call divide(B,mu)

         ! J_cc = curl(B_cc)
         call curl(J,B,g)

         ! B = B*mu - B0
         ! call multiply(B,mu)
         call subtract(B,B0)
       end subroutine

       subroutine computeMagneticEnergy(ind,B,B0,g,ss_MHD)
         implicit none
         type(induction),intent(inout) :: ind
         type(vectorField),intent(in) :: B,B0
         type(grid),intent(in) :: g
         type(solverSettings),intent(in) :: ss_MHD
         real(cp) :: K_energy
         integer,dimension(3) :: Nin1,Nin2,Nice1,Nice2,Nici1,Nici2
         Nin1  = ind%SD%Nin1; Nin2  = ind%SD%Nin2; Nice1 = ind%SD%Nice1
         Nice2 = ind%SD%Nice2; Nici1 = ind%SD%Nici1; Nici2 = ind%SD%Nici2
          if (computeKB.and.getExportTransient(ss_MHD).or.ind%nstep.eq.0) then
           ! call totalEnergy(K_energy,ind%B,ind%g) ! Sergey uses interior...
           call totalEnergy(K_energy,&
             B%x(Nici1(1):Nici2(1),Nici1(2):Nici2(2),Nici1(3):Nici2(3)),&
             B%y(Nici1(1):Nici2(1),Nici1(2):Nici2(2),Nici1(3):Nici2(3)),&
             B%z(Nici1(1):Nici2(1),Nici1(2):Nici2(2),Nici1(3):Nici2(3)),&
             g)
           call set(ind%KB_energy,ind%nstep,K_energy)
           call apply(ind%KB_energy)
          endif
          if (computeKB0.and.getExportTransient(ss_MHD).or.ind%nstep.eq.0) then
           ! call totalEnergy(K_energy,B0,ind%g) ! Sergey uses interior...
           call totalEnergy(K_energy,&
             B0%x(Nici1(1):Nici2(1),Nici1(2):Nici2(2),Nici1(3):Nici2(3)),&
             B0%y(Nici1(1):Nici2(1),Nici1(2):Nici2(2),Nici1(3):Nici2(3)),&
             B0%z(Nici1(1):Nici2(1),Nici1(2):Nici2(2),Nici1(3):Nici2(3)),&
             g)
           call set(ind%KB0_energy,ind%nstep,K_energy)
           call apply(ind%KB0_energy)
          endif
       end subroutine

       ! ********************* AUX *****************************

       subroutine embedVelocity(ind,U_fi,g)
         implicit none
         type(induction),intent(inout) :: ind
         type(vectorField),intent(in) :: U_fi ! Raw momentum velocity
         type(grid),intent(in) :: g ! Momentum grid
         type(vectorField) :: temp
         integer,dimension(3) :: Ni
         integer :: embedType,dir
         logical,dimension(4) :: usedVelocity

         usedVelocity = (/.true.,.true.,.false.,.false./)

         if (usedVelocity(1)) then ! Edge - 2 interpolations
           call allocateX(temp,g%c(1)%sc,g%c(2)%sn,g%c(3)%sn)
           call allocateY(temp,g%c(1)%sn,g%c(2)%sc,g%c(3)%sn)
           call allocateZ(temp,g%c(1)%sn,g%c(2)%sn,g%c(3)%sc)
           call face2Edge(temp%x,U_fi%x,g,1,1)
           call face2Edge(temp%y,U_fi%x,g,1,2)
           call face2Edge(temp%z,U_fi%x,g,1,3)
           call embedEdge(ind%U_E,temp,ind%SD,g)
           call face2Edge(temp%x,U_fi%y,g,2,1)
           call face2Edge(temp%y,U_fi%y,g,2,2)
           call face2Edge(temp%z,U_fi%y,g,2,3)
           call embedEdge(ind%V_E,temp,ind%SD,g)
           call face2Edge(temp%x,U_fi%z,g,3,1)
           call face2Edge(temp%y,U_fi%z,g,3,2)
           call face2Edge(temp%z,U_fi%z,g,3,3)
           call embedEdge(ind%W_E,temp,ind%SD,g)
           call delete(temp)
         endif

         if (usedVelocity(2)) then ! CC - 1 interpolation
           call allocateX(temp,g%c(1)%sc,g%c(2)%sc,g%c(3)%sc)
           call allocateY(temp,g%c(1)%sc,g%c(2)%sc,g%c(3)%sc)
           call allocateZ(temp,g%c(1)%sc,g%c(2)%sc,g%c(3)%sc)
           call face2CellCenter(temp%x,U_fi%x,g,1)
           call face2CellCenter(temp%y,U_fi%y,g,2)
           call face2CellCenter(temp%z,U_fi%z,g,3)
           call embedCC(ind%U_cct,temp,ind%SD,g)
           call delete(temp)
         endif

         if (usedVelocity(3)) then ! Face - no interpolations
           call embedFace(ind%U_Ft,U_Fi,ind%SD,g)
         endif
         ! if (usedVelocity(4)) then ! Node - 3 interpolations (not needed for any solvers)
           ! call allocateX(temp,g%c(1)%sc,g%c(2)%sn,g%c(3)%sn)
           ! call allocateY(temp,g%c(1)%sn,g%c(2)%sc,g%c(3)%sn)
           ! call allocateZ(temp,g%c(1)%sn,g%c(2)%sn,g%c(3)%sc)
           ! call face2Node(temp%x,U_fi%x,g,1)
           ! call face2Node(temp%y,U_fi%x,g,1)
           ! call face2Node(temp%z,U_fi%x,g,1)
           ! call embedNode(ind%U_N,temp,Nin1,Nin2,g)
           ! call face2Node(temp%x,U_fi%y,g,2)
           ! call face2Node(temp%y,U_fi%y,g,2)
           ! call face2Node(temp%z,U_fi%y,g,2)
           ! call embedNode(ind%V_N,temp,Nin1,Nin2,g)
           ! call face2Node(temp%x,U_fi%z,g,3)
           ! call face2Node(temp%y,U_fi%z,g,3)
           ! call face2Node(temp%z,U_fi%z,g,3)
           ! call embedNode(ind%W_N,temp,Nin1,Nin2,g)
           ! call delete(temp)
         ! endif
       end subroutine

       subroutine perturbAll(f,g)
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: f
         type(grid),intent(in) :: g
         real(cp),dimension(3) :: wavenum,eps
         integer,dimension(3) :: s
         integer :: i,j,k
         s = shape(f)
         wavenum = real(0.1,cp)
         eps = real(0.01,cp)
         if (all((/(s(i).eq.g%c(i)%sn,i=1,3)/))) then
           !$OMP PARALLEL DO
           do k=1,s(3); do j=1,s(2); do i=1,s(1)
             f(i,j,k) = f(i,j,k)*(real(1.0,cp) + eps(1)*sin(wavenum(1)*PI*g%c(1)%hn(i)) +&
                                                 eps(2)*sin(wavenum(2)*PI*g%c(2)%hn(j)) +&
                                                 eps(3)*sin(wavenum(3)*PI*g%c(3)%hn(k)) )
           enddo; enddo; enddo
           !$OMP END PARALLEL DO
         elseif (all((/(s(i).eq.g%c(i)%sc,i=1,3)/))) then
           !$OMP PARALLEL DO
           do k=1,s(3); do j=1,s(2); do i=1,s(1)
             f(i,j,k) = f(i,j,k)*(real(1.0,cp) + eps(1)*sin(wavenum(1)*PI*g%c(1)%hc(i)) +&
                                                 eps(2)*sin(wavenum(2)*PI*g%c(2)%hc(j)) +&
                                                 eps(3)*sin(wavenum(3)*PI*g%c(3)%hc(k)) )
           enddo; enddo; enddo
           !$OMP END PARALLEL DO
         else
          stop 'Error: unmatched case in perturb in inductionSolver.f90'
         endif
       end subroutine

       subroutine perturb(f,g)
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: f
         type(grid),intent(in) :: g
         real(cp),dimension(3) :: wavenum,eps
         integer,dimension(3) :: s
         integer :: i,j,k
         s = shape(f)
         wavenum = real(10.0,cp)
         eps = real(0.1,cp)
         if (all((/(s(i).eq.g%c(i)%sn,i=1,3)/))) then
           !$OMP PARALLEL DO
           do k=1,s(3); do j=1,s(2); do i=1,s(1)
             f(i,j,k) = f(i,j,k)*(real(1.0,cp) + eps(2)*sin(wavenum(2)*PI*g%c(2)%hn(j)) +&
                                                 eps(3)*sin(wavenum(3)*PI*g%c(3)%hn(k)) )
           enddo; enddo; enddo
           !$OMP END PARALLEL DO
         elseif (all((/(s(i).eq.g%c(i)%sc,i=1,3)/))) then
           !$OMP PARALLEL DO
           do k=1,s(3); do j=1,s(2); do i=1,s(1)
             f(i,j,k) = f(i,j,k)*(real(1.0,cp) + eps(2)*sin(wavenum(2)*PI*g%c(2)%hc(j)) +&
                                                 eps(3)*sin(wavenum(3)*PI*g%c(3)%hc(k)) )
           enddo; enddo; enddo
           !$OMP END PARALLEL DO
         else
          stop 'Error: unmatched case in perturb in inductionSolver.f90'
         endif
       end subroutine

       subroutine uniformify(ind,U)
         implicit none
         type(induction),intent(inout) :: ind
         type(vectorField),intent(inout) :: U
         integer,dimension(3) :: s
         integer :: i
         integer,dimension(3) :: Nin1,Nin2,Nice1,Nice2,Nici1,Nici2
         Nin1  = ind%SD%Nin1; Nin2  = ind%SD%Nin2; Nice1 = ind%SD%Nice1
         Nice2 = ind%SD%Nice2; Nici1 = ind%SD%Nici1; Nici2 = ind%SD%Nici2
         s = shape(U%x)
         do i=1,s(1)
           U%x(i,:,:) = U%x(Nici1(1)+2,:,:)
         enddo
       end subroutine

       subroutine uniformifyX(ind,U)
         implicit none
         type(induction),intent(inout) :: ind
         type(vectorField),intent(inout) :: U
         integer,dimension(3) :: s
         integer :: i
         integer,dimension(3) :: Nin1,Nin2,Nice1,Nice2,Nici1,Nici2
         Nin1  = ind%SD%Nin1; Nin2  = ind%SD%Nin2; Nice1 = ind%SD%Nice1
         Nice2 = ind%SD%Nice2; Nici1 = ind%SD%Nici1; Nici2 = ind%SD%Nici2
         s = shape(U%x)
         do i=1,s(1)
           U%x(i,:,:) = U%x((Nici1(1)+Nici2(1))/2,:,:)
         enddo
         s = shape(U%y)
         do i=1,s(1)
           U%y(i,:,:) = U%y((Nici1(1)+Nici2(1))/2,:,:)
         enddo
         s = shape(U%z)
         do i=1,s(1)
           U%z(i,:,:) = U%z((Nici1(1)+Nici2(1))/2,:,:)
         enddo
       end subroutine

       end module