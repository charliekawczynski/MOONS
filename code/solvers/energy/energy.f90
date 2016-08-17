       module energy_mod
       use current_precision_mod
       use simParams_mod
       use IO_tools_mod
       use IO_Auxiliary_mod
       use IO_SF_mod
       use IO_VF_mod
       use export_raw_processed_mod
       use SF_mod
       use VF_mod
       use mesh_mod
       use domain_mod
       use dir_tree_mod
       use string_mod
       use path_mod
       use print_export_mod
       use PCG_mod
       use PCG_solver_mod
       use matrix_free_params_mod
       use matrix_free_operators_mod
       use preconditioners_mod

       use energy_aux_mod
       use energy_solver_mod
       use init_TBCs_mod
       use init_Tfield_mod
       use init_K_mod

       use ops_embedExtract_mod
       use norms_mod
       use ops_aux_mod
       use ops_interp_mod
       use ops_discrete_mod
       use BCs_mod
       use apply_BCs_mod
       use probe_base_mod

       implicit none

       private
       public :: energy
       public :: init,delete,display,print,export,import ! Essentials
       public :: solve,exportTransient,export_tec

       type energy
         ! --- Vector fields ---
         type(SF) :: T,temp_CC1,temp_CC2   ! CC data
         type(VF) :: temp_F,k              ! Face data
         type(VF) :: U_F                   ! Face data
         type(VF) :: gravity               ! CC data
         type(VF) :: temp_CC1_VF           ! CC data
         type(VF) :: temp_CC2_VF           ! CC data
         ! --- Scalar fields ---
         type(SF) :: divQ                  ! CC data
         type(SF) :: vol_CC
         type(SF) :: Q_source

         type(errorProbe) :: transient_divQ
         type(mesh) :: m
         type(domain) :: D
         type(norms) :: norm_divQ
         type(matrix_free_params) :: MFP

         integer :: nstep             ! Nth time step
         integer :: N_nrg             ! Maximum number iterations in solving T (if iterative)
         real(cp) :: dTime            ! Time step
         real(cp) :: time             ! Time
         real(cp) :: tol_nrg             ! Time

         type(PCG_Solver_SF) :: PCG_T
         real(cp) :: Re,Pr,Ec,Ha  ! Reynolds, Prandtl, Eckert, Hartmann
       end type

       interface init;               module procedure init_energy;             end interface
       interface delete;             module procedure delete_energy;           end interface
       interface display;            module procedure display_energy;          end interface
       interface print;              module procedure print_energy;            end interface
       interface export;             module procedure export_energy;           end interface
       interface import;             module procedure import_energy;           end interface

       interface solve;              module procedure solve_energy;            end interface
       interface exportTransient;    module procedure energyExportTransient;   end interface
       interface export_tec;         module procedure export_tec_energy;       end interface

       contains

       ! **********************************************************
       ! ********************* ESSENTIALS *************************
       ! **********************************************************

       subroutine init_energy(nrg,m,D,N_nrg,tol_nrg,dTime,Re,Pr,Ec,Ha,DT)
         implicit none
         type(energy),intent(inout) :: nrg
         type(mesh),intent(in) :: m
         type(domain),intent(in) :: D
         real(cp),intent(in) :: tol_nrg,dTime,Re,Pr,Ec,Ha
         integer,intent(in) :: N_nrg
         type(dir_tree),intent(in) :: DT
         integer :: temp_unit
         type(SF) :: k_cc,prec_T
         write(*,*) 'Initializing energy:'
         nrg%dTime = dTime
         nrg%N_nrg = N_nrg
         nrg%tol_nrg = tol_nrg
         nrg%Re = Re
         nrg%Pr = Pr
         nrg%Ec = Ec
         nrg%Ha = Ha

         call init(nrg%m,m)
         call init(nrg%D,D)

         call init_CC(nrg%T,m,0.0_cp)
         call init_CC(nrg%Q_source,m,0.0_cp)
         call init_CC(nrg%temp_CC2,m,0.0_cp)
         call init_Face(nrg%temp_F,m,0.0_cp)
         call init_Face(nrg%k,m,0.0_cp)
         call init_Face(nrg%U_F,m,0.0_cp)
         call init_CC(nrg%temp_CC1,m,0.0_cp)
         call init_CC(nrg%gravity,m,0.0_cp)
         call init_CC(nrg%temp_CC1_VF,m,0.0_cp)
         call init_CC(nrg%temp_CC2_VF,m,0.0_cp)

         ! --- Scalar Fields ---
         call init_CC(nrg%divQ,m)
         call init_CC(nrg%vol_CC,m)
         call volume(nrg%vol_CC,m)
         write(*,*) '     Fields allocated'

         ! --- Initialize Fields ---
         call init_TBCs(nrg%T,nrg%m)
         if (solveEnergy) call print_BCs(nrg%T,'T')
         if (solveEnergy) call export_BCs(nrg%T,str(DT%params),'T')
         write(*,*) '     BCs initialized'

         call initTfield(nrg%T,m,str(DT%T))
         write(*,*) '     T-field initialized'

         call apply_BCs(nrg%T,m)
         write(*,*) '     BCs applied'

         call init_CC(k_cc,m,0.0_cp)
         call initK(k_cc,nrg%D)
         call cellCenter2Face(nrg%k,k_cc,m)
         call delete(k_cc)
         write(*,*) '     Materials initialized'

         call init(nrg%transient_divQ,str(DT%T),'transient_divQ',.not.restartT)
         call export(nrg%transient_divQ)

         nrg%MFP%c_nrg = -0.5_cp*nrg%dTime/(nrg%Re*nrg%Pr)
         call init(prec_T,nrg%T)
         call prec_lap_SF(prec_T,nrg%m)
         ! call prec_identity_SF(prec_T) ! For ordinary CG
         call init(nrg%PCG_T,nrg_diffusion,nrg_diffusion_explicit,prec_T,nrg%m,&
         nrg%tol_nrg,nrg%MFP,nrg%T,nrg%temp_F,str(DT%T),'T',.false.,.false.)
         call delete(prec_T)

         temp_unit = newAndOpen(str(DT%params),'info_nrg')
         call print(nrg)
         close(temp_unit)

         write(*,*) '     probes initialized'

         if (restartT) then
         call readLastStepFromFile(nrg%nstep,str(DT%params),'nstep_nrg')
         else; nrg%nstep = 0
         endif
         nrg%time = 0.0_cp
         write(*,*) '     Finished'
       end subroutine

       subroutine delete_energy(nrg)
         implicit none
         type(energy),intent(inout) :: nrg

         call delete(nrg%T)
         call delete(nrg%Q_source)
         call delete(nrg%temp_F)
         call delete(nrg%k)
         call delete(nrg%temp_CC1)
         call delete(nrg%temp_CC2)

         call delete(nrg%U_F)
         call delete(nrg%gravity)
         call delete(nrg%temp_CC1_VF)
         call delete(nrg%temp_CC2_VF)

         call delete(nrg%divQ)
         call delete(nrg%vol_CC)

         call delete(nrg%transient_divQ)
         call delete(nrg%m)
         call delete(nrg%D)
         call delete(nrg%PCG_T)

         write(*,*) 'energy object deleted'
       end subroutine

       subroutine display_energy(nrg,un)
         implicit none
         type(energy),intent(in) :: nrg
         integer,intent(in) :: un
         write(un,*) '**************************************************************'
         write(un,*) '*************************** ENERGY ***************************'
         write(un,*) '**************************************************************'
         write(un,*) 'Re,Pr = ',nrg%Re,nrg%Pr
         write(un,*) 'Ec,Ha = ',nrg%Ec,nrg%Ha
         write(un,*) 't,dt = ',nrg%time,nrg%dTime
         write(un,*) 'solveTMethod,N_nrg = ',solveTMethod,nrg%N_nrg
         write(un,*) 'tol_nrg = ',nrg%tol_nrg
         call displayPhysicalMinMax(nrg%T,'T',un)
         call displayPhysicalMinMax(nrg%divQ,'divQ',un)
         write(un,*) ''
         call print(nrg%m)
         write(un,*) ''
       end subroutine

       subroutine print_energy(nrg)
         implicit none
         type(energy),intent(in) :: nrg
         call display(nrg,6)
       end subroutine

       subroutine export_energy(nrg,DT)
         implicit none
         type(energy),intent(in) :: nrg
         type(dir_tree),intent(in) :: DT
         call export(nrg%T   ,str(DT%restart),'T_nrg')
         call export(nrg%U_F ,str(DT%restart),'U_nrg')
         call export(nrg%k   ,str(DT%restart),'k_nrg')
       end subroutine

       subroutine import_energy(nrg,DT)
         implicit none
         type(energy),intent(inout) :: nrg
         type(dir_tree),intent(in) :: DT
         call import(nrg%T   ,str(DT%restart),'T_nrg')
         call import(nrg%U_F ,str(DT%restart),'U_nrg')
         call import(nrg%k   ,str(DT%restart),'k_nrg')
       end subroutine

       ! **********************************************************
       ! **********************************************************
       ! **********************************************************

       subroutine export_tec_energy(nrg,DT)
         implicit none
         type(energy),intent(inout) :: nrg
         type(dir_tree),intent(in) :: DT
         if (solveEnergy) then
           write(*,*) 'export_tec_energy at nrg%nstep = ',nrg%nstep
           call export_processed(nrg%m,nrg%T,str(DT%T),'T',0)
           call export_raw(nrg%m,nrg%T,str(DT%T),'T',0)
           call export_raw(nrg%m,nrg%divQ,str(DT%T),'divQ',0)
           write(*,*) '     finished'
         endif
       end subroutine

       subroutine energyExportTransient(nrg)
         implicit none
         type(energy),intent(inout) :: nrg
         call compute(nrg%norm_divQ,nrg%divQ,nrg%vol_CC)
         call set(nrg%transient_divQ,nrg%nstep,nrg%time,nrg%norm_divQ%L2)
         call apply(nrg%transient_divQ)
       end subroutine

       subroutine solve_energy(nrg,U,PE,DT)
         implicit none
         type(energy),intent(inout) :: nrg
         type(VF),intent(in) :: U
         type(print_export),intent(in) :: PE
         type(dir_tree),intent(in) :: DT
         logical :: exportNow,exportNowT

         call assign(nrg%gravity%x,1.0_cp)

         call embed_velocity_F(nrg%U_F,U,nrg%D)

         select case (solveTMethod)
         case (1)
         call explicitEuler(nrg%T,nrg%U_F,nrg%dTime,nrg%Re,&
         nrg%Pr,nrg%m,nrg%temp_CC1,nrg%temp_CC2,nrg%temp_F)
         
         case (2) ! O2 time marching
         call explicitEuler(nrg%T,nrg%U_F,nrg%dTime,nrg%Re,&
         nrg%Pr,nrg%m,nrg%temp_CC1,nrg%temp_CC2,nrg%temp_F)

         case (3) ! Diffusion implicit
         call diffusion_implicit(nrg%PCG_T,nrg%T,nrg%U_F,nrg%dTime,nrg%Re,&
         nrg%Pr,nrg%m,nrg%N_nrg,PE%transient_0D,nrg%temp_CC1,nrg%temp_CC2,nrg%temp_F)

         case (4)
         if (nrg%nstep.le.1) call volumetric_heating_equation(nrg%Q_source,nrg%m,nrg%Re,nrg%Pr)

         call explicitEuler_with_source(nrg%T,nrg%U_F,nrg%dTime,nrg%Re,&
         nrg%Pr,nrg%m,nrg%Q_source,nrg%temp_CC1,nrg%temp_CC2,nrg%temp_F)

         case (5)
         if (nrg%nstep.le.1) call volumetric_heating_equation(nrg%Q_source,nrg%m,nrg%Re,nrg%Pr)
         call CN_with_source(nrg%PCG_T,nrg%T,nrg%U_F,nrg%dTime,nrg%Re,&
         nrg%Pr,nrg%m,nrg%Q_source,nrg%N_nrg,PE%transient_0D,nrg%temp_CC1,nrg%temp_CC2,nrg%temp_F)

         case default; stop 'Erorr: bad solveTMethod value in solve_energy in energy.f90'
         end select
         nrg%nstep = nrg%nstep + 1
         nrg%time = nrg%time + nrg%dTime ! This only makes sense for finite Rem

         ! ********************* POST SOLUTION COMPUTATIONS *********************

         ! ********************* POST SOLUTION PRINT/EXPORT *********************

         if (PE%transient_0D) then
           call compute_Q(nrg%temp_F,nrg%T,nrg%k,nrg%m)
           call compute_divQ(nrg%divQ,nrg%temp_F,nrg%m)
           call exportTransient(nrg)
         endif

         if (PE%info) then
           call print(nrg)
           exportNow = readSwitchFromFile(str(DT%params),'exportNow')
           exportNowT = readSwitchFromFile(str(DT%params),'exportNowT')
         else; exportNow = .false.; exportNowT = .false.
         endif

         if (nrg%nstep.eq.9) call export_tec(nrg,DT)
         if (PE%solution.or.exportNowT.or.exportNow) then
           call export(nrg,DT)
           call export_tec(nrg,DT)
           call writeSwitchToFile(.false.,str(DT%params),'exportNowT')
         endif
       end subroutine

       end module