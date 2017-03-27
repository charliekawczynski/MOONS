       module induction_mod
       use current_precision_mod
       use sim_params_mod
       use IO_tools_mod
       use SF_mod
       use VF_mod
       use TF_mod
       use IO_export_mod
       use IO_import_mod
       use dir_tree_mod
       use string_mod
       use path_mod
       use export_raw_processed_mod
       use export_raw_processed_symmetry_mod
       use export_processed_FPL_mod
       use export_frequency_mod
       use export_now_mod
       use refine_mesh_mod
       use assign_B0_vs_t_mod
       use datatype_conversion_mod

       use mesh_stencils_mod
       use init_B_BCs_mod
       use init_Bstar_field_mod
       use init_phi_BCs_mod
       use init_B_field_mod
       use init_phi_field_mod
       use init_B0_field_mod
       use init_B_interior_mod
       use init_J_interior_mod
       use init_Sigma_mod
       use ops_embedExtract_mod
       use clean_divergence_mod
       use BC_funcs_mod

       use iter_solver_params_mod
       use time_marching_params_mod

       use probe_mod
       use ops_norms_mod
       use var_set_mod
       use mirror_props_mod

       use mesh_domain_mod
       use grid_mod
       use mesh_mod
       use norms_mod
       use ops_del_mod
       use ops_aux_mod
       use ops_interp_mod
       use ops_discrete_mod
       use boundary_conditions_mod
       use apply_BCs_mod
       use ops_advect_mod
       use time_marching_methods_mod
       use induction_solver_mod
       use preconditioners_mod
       use PCG_mod
       use matrix_free_params_mod
       use matrix_free_operators_mod
       use induction_aux_mod
       use E_M_Budget_mod

       implicit none

       private
       public :: induction
       public :: init,delete,display,print,export,import ! Essentials
       public :: solve,export_tec,compute_export_E_M_budget

       type induction
         ! --- Tensor fields ---
         type(TF) :: U_E,temp_E_TF                    ! Edge data
         type(TF) :: temp_F1_TF,temp_F2_TF            ! Face data

         ! --- Vector fields ---
         type(VF) :: F,Fnm1                           ! Face data
         type(VF) :: J,temp_E                         ! Edge data
         type(VF) :: B,Bnm1,B0,B_interior,temp_F1,temp_F2  ! Face data
         type(VF) :: Bstar                            ! Intermediate magnetic field
         type(VF) :: dB0dt
         type(VF) :: temp_CC_VF                       ! CC data
         type(VF) :: sigmaInv_edge
         type(VF) :: J_interior
         type(VF) :: curlUCrossB
         type(VF) :: CC_VF_fluid,CC_VF_sigma

         ! --- Scalar fields ---
         type(SF) :: sigmaInv_CC
         type(SF) :: divB,divJ,phi,temp_CC         ! CC data

         ! --- Solvers ---
         type(PCG_solver_VF) :: PCG_B
         type(PCG_solver_SF) :: PCG_cleanB

         ! Subscripts:
         ! Magnetic field:
         type(probe),dimension(3) :: ME,ME_fluid,ME_conductor ! 1 = total, 2 = applied, 3 induced
         type(probe) :: JE,JE_fluid
         type(probe) :: probe_divB,probe_divJ
         type(probe),dimension(3) :: probe_dB0dt,probe_B0

         type(mesh) :: m
         type(mesh_domain) :: MD_fluid,MD_sigma ! Latter for vacuum case

         type(sim_params) :: SP

         logical :: suppress_warning
       end type

       interface init;                 module procedure init_induction;                end interface
       interface delete;               module procedure delete_induction;              end interface
       interface display;              module procedure display_induction;             end interface
       interface print;                module procedure print_induction;               end interface
       interface export;               module procedure export_induction;              end interface
       interface import;               module procedure import_induction;              end interface

       interface solve;                module procedure solve_induction;               end interface
       interface export_tec;           module procedure export_tec_induction;          end interface

       interface set_sigma_inv;        module procedure set_sigma_inv_ind;             end interface
       interface init_matrix_based_ops;module procedure init_matrix_based_ops_ind;     end interface

       interface export_unsteady_0D;    module procedure export_unsteady_0D_ind;       end interface
       interface export_unsteady_1D;    module procedure export_unsteady_1D_ind;       end interface
       interface export_unsteady_2D;    module procedure export_unsteady_2D_ind;       end interface
       interface export_unsteady_3D;    module procedure export_unsteady_3D_ind;       end interface

       contains

       ! **********************************************************
       ! ********************* ESSENTIALS *************************
       ! **********************************************************

       subroutine init_induction(ind,m,SP,DT,MD_fluid,MD_sigma)
         implicit none
         type(induction),intent(inout) :: ind
         type(mesh),intent(in) :: m
         type(sim_params),intent(in) :: SP
         type(mesh_domain),intent(in) :: MD_fluid,MD_sigma
         type(dir_tree),intent(in) :: DT
         type(TF) :: TF_face,sigmaInv_edge_TF
         integer :: temp_unit
         write(*,*) 'Initializing induction:'

         call init(ind%SP,SP)

         call init(ind%m,m)
         call init(ind%MD_fluid,MD_fluid)
         call init(ind%MD_sigma,MD_sigma)
         call init_CC(ind%CC_VF_fluid,m,MD_fluid); call assign(ind%CC_VF_fluid,0.0_cp)
         call init_CC(ind%CC_VF_sigma,m,MD_sigma); call assign(ind%CC_VF_sigma,0.0_cp)
         ! --- tensor,vector and scalar fields ---
         call init_Face(ind%B_interior     ,m,ind%MD_sigma); call assign(ind%B_interior,0.0_cp)
         call init_Edge(ind%J_interior     ,m,ind%MD_sigma); call assign(ind%J_interior,0.0_cp)
         call init_Edge(ind%U_E            ,m,0.0_cp)
         call init_Edge(ind%temp_E_TF      ,m,0.0_cp)
         call init_Face(ind%temp_F1_TF     ,m,0.0_cp)
         call init_Face(ind%temp_F2_TF     ,m,0.0_cp)
         call init_Face(ind%F              ,m,0.0_cp)
         call init_Face(ind%Fnm1           ,m,0.0_cp)
         call init_Face(ind%B              ,m,0.0_cp)
         call init_Face(ind%Bnm1           ,m,0.0_cp)
         call init_Face(ind%B0             ,m,0.0_cp)
         call init_Face(ind%dB0dt          ,m,0.0_cp)
         call init_CC(ind%temp_CC_VF       ,m,0.0_cp)
         call init_Edge(ind%J              ,m,0.0_cp)
         call init_Face(ind%curlUCrossB    ,m,0.0_cp)
         call init_Edge(ind%temp_E         ,m,0.0_cp)
         call init_Edge(ind%sigmaInv_edge  ,m,0.0_cp)
         call init_Face(ind%temp_F1        ,m,0.0_cp)
         call init_Face(ind%temp_F2        ,m,0.0_cp)
         call init_CC(ind%phi              ,m,0.0_cp)
         call init_CC(ind%temp_CC          ,m,0.0_cp)
         call init_CC(ind%divB             ,m,0.0_cp)
         call init_Node(ind%divJ           ,m,0.0_cp)
         call init_CC(ind%sigmaInv_CC      ,m,0.0_cp)

         write(*,*) '     Fields allocated'

         ! --- Initialize Fields ---
         call init_B_BCs(ind%B,m,ind%SP);     write(*,*) '     B BCs initialized'
         call update_BC_vals(ind%B)
         call init_phi_BCs(ind%phi,m,ind%SP); write(*,*) '     phi BCs initialized'
         call update_BC_vals(ind%phi)

         call init_B0_field(ind%B0,m,ind%SP,str(DT%B%restart))
         call init_B_field(ind%B,m,ind%SP,str(DT%B%restart))
         call init_phi_field(ind%phi,m,ind%SP,str(DT%phi%restart))
         call assign(ind%Bnm1,ind%B)

         if (ind%SP%IT%unsteady_B0%add) call assign_B0_vs_t(ind%B0,ind%SP%VS%B%TMP)
         call multiply(ind%B0,SP%IT%B_applied%scale)

         write(*,*) '     B-field initialized'
         ! call initB_interior(ind%B_interior,m,ind%MD_sigma,str(DT%B%restart))
         ! call initJ_interior(ind%J_interior,m,ind%MD_sigma,str(DT%J%restart))
         call assign_ghost_XPeriodic(ind%B_interior,0.0_cp)
         call apply_BCs(ind%B);                           write(*,*) '     BCs applied'

         call init(ind%Bstar,ind%B)
         if (SP%VS%B%SS%prescribed_BCs) call set_prescribed_BCs(ind%Bstar)
         call init_Bstar_field(ind%Bstar,m,ind%B,ind%SP,str(DT%B%restart))

         write(*,*) '     Intermediate B-field initialized'

         if (ind%SP%VS%B%SS%solve) call print_BCs(ind%B,'B')
         if (ind%SP%VS%B%SS%solve) call export_BCs(ind%B,str(DT%B%BCs),'B')
         if (ind%SP%VS%B%SS%solve) call print_BCs(ind%phi,'phi')
         if (ind%SP%VS%B%SS%solve) call export_BCs(ind%phi,str(DT%phi%BCs),'phi')

         ! ******************** MATERIAL PROPERTIES ********************
         call set_sigma_inv(ind)
         write(*,*) '     Materials initialized'
         if (ind%SP%EL%export_mat_props) call export_raw(m,ind%sigmaInv_edge,str(DT%mat),'sigmaInv',0)

         ! *************************************************************

         call compute_J_ind(ind)

         if (ind%SP%IT%unsteady_B0%add) then
           call init(ind%probe_dB0dt(1),str(DT%B%energy),'dB0dt_x',ind%SP%VS%B%SS%restart,.true.)
           call init(ind%probe_dB0dt(2),str(DT%B%energy),'dB0dt_y',ind%SP%VS%B%SS%restart,.true.)
           call init(ind%probe_dB0dt(3),str(DT%B%energy),'dB0dt_z',ind%SP%VS%B%SS%restart,.true.)
           call init(ind%probe_B0(1)   ,str(DT%B%energy),'B0_x',   ind%SP%VS%B%SS%restart,.true.)
           call init(ind%probe_B0(2)   ,str(DT%B%energy),'B0_y',   ind%SP%VS%B%SS%restart,.true.)
           call init(ind%probe_B0(3)   ,str(DT%B%energy),'B0_z',   ind%SP%VS%B%SS%restart,.true.)
         endif
         call init(ind%probe_divB,str(DT%B%residual),'transient_divB',ind%SP%VS%B%SS%restart,.true.)
         call init(ind%probe_divJ,str(DT%J%residual),'transient_divJ',ind%SP%VS%B%SS%restart,.true.)
         call init(ind%JE,        str(DT%J%energy),'JE',            ind%SP%VS%B%SS%restart,.true.)
         call init(ind%JE_fluid,  str(DT%J%energy),'JE_fluid',      ind%SP%VS%B%SS%restart,.true.)
         call init(ind%ME(1)          ,str(DT%B%energy),'ME',           ind%SP%VS%B%SS%restart,.false.)
         call init(ind%ME_fluid(1)    ,str(DT%B%energy),'ME_fluid',     ind%SP%VS%B%SS%restart,.false.)
         call init(ind%ME_conductor(1),str(DT%B%energy),'ME_conductor', ind%SP%VS%B%SS%restart,.false.)
         call init(ind%ME(2)          ,str(DT%B%energy),'ME0',          ind%SP%VS%B%SS%restart,.false.)
         call init(ind%ME_fluid(2)    ,str(DT%B%energy),'ME0_fluid',    ind%SP%VS%B%SS%restart,.false.)
         call init(ind%ME_conductor(2),str(DT%B%energy),'ME0_conductor',ind%SP%VS%B%SS%restart,.false.)
         call init(ind%ME(3)          ,str(DT%B%energy),'ME1',          ind%SP%VS%B%SS%restart,.false.)
         call init(ind%ME_fluid(3)    ,str(DT%B%energy),'ME1_fluid',    ind%SP%VS%B%SS%restart,.false.)
         call init(ind%ME_conductor(3),str(DT%B%energy),'ME1_conductor',ind%SP%VS%B%SS%restart,.false.)

         write(*,*) '     B/J probes initialized'

         ! ********** SET CLEANING PROCEDURE SOLVER SETTINGS *************

         ! Initialize multigrid
         temp_unit = new_and_open(str(DT%params),'info_ind')
         call display(ind,temp_unit)
         call close_and_message(temp_unit,str(DT%params),'info_ind')

         write(*,*) '     About to assemble curl-curl matrix'
         if (ind%SP%matrix_based) call init_matrix_based_ops(ind)

         call init_Edge(sigmaInv_edge_TF%x,m,0.0_cp) ! x-component used in matrix_free_operators.f90
         call assign(sigmaInv_edge_TF%x,ind%sigmaInv_edge)
         call init(ind%PCG_B,ind_diffusion,ind_diffusion_explicit,prec_ind_VF,ind%m,&
         ind%SP%VS%B%ISP,ind%SP%VS%B%MFP,ind%Bstar,sigmaInv_edge_TF,str(DT%B%residual),'B',.false.,.false.)
         call delete(sigmaInv_edge_TF)
         write(*,*) '     PCG Solver initialized for B'

         call init_Face(TF_face%x,m,0.0_cp) ! x-component used in matrix_free_operators.f90
         call init(ind%PCG_cleanB,Lap_uniform_SF,Lap_uniform_SF_explicit,prec_lap_SF,&
         ind%m,ind%SP%VS%phi%ISP,ind%SP%VS%phi%MFP,ind%phi,TF_face,str(DT%phi%residual),'phi',.false.,.false.)
         call delete(TF_face)
         write(*,*) '     PCG Solver initialized for phi'

         write(*,*) '     Finished'
         ! if (restart_induction) call import(ind,DT)
       end subroutine

       subroutine delete_induction(ind)
         implicit none
         type(induction),intent(inout) :: ind
         call delete(ind%temp_E_TF)
         call delete(ind%temp_F1_TF)
         call delete(ind%temp_F2_TF)
         call delete(ind%U_E)

         call delete(ind%F)
         call delete(ind%Fnm1)
         call delete(ind%B)
         call delete(ind%Bnm1)
         call delete(ind%Bstar)
         call delete(ind%B_interior)
         call delete(ind%B0)
         call delete(ind%dB0dt)
         call delete(ind%J)
         call delete(ind%J_interior)
         call delete(ind%curlUCrossB)
         call delete(ind%CC_VF_fluid)
         call delete(ind%CC_VF_sigma)
         call delete(ind%temp_CC_VF)
         call delete(ind%temp_E)
         call delete(ind%temp_F1)
         call delete(ind%temp_F2)
         call delete(ind%sigmaInv_edge)

         call delete(ind%divB)
         call delete(ind%divJ)
         call delete(ind%phi)
         call delete(ind%temp_CC)

         call delete(ind%m)
         call delete(ind%MD_fluid)
         call delete(ind%MD_sigma)

         call delete(ind%probe_divB)
         call delete(ind%probe_divJ)
         call delete(ind%probe_dB0dt)
         call delete(ind%probe_B0)

         call delete(ind%ME)
         call delete(ind%ME_fluid)
         call delete(ind%ME_conductor)
         call delete(ind%JE)
         call delete(ind%JE_fluid)

         call delete(ind%PCG_cleanB)
         call delete(ind%PCG_B)
         call delete(ind%SP)

         write(*,*) 'Induction object deleted'
       end subroutine

       subroutine display_induction(ind,un)
         implicit none
         type(induction),intent(in) :: ind
         integer,intent(in) :: un
         write(un,*) '**************************************************************'
         write(un,*) '************************** MAGNETIC **************************'
         write(un,*) '**************************************************************'
         write(un,*) 'Rem,finite_Rem,include_vacuum = ',ind%SP%DP%Rem,ind%SP%finite_Rem,ind%SP%include_vacuum
         write(un,*) 't,dt = ',ind%SP%VS%B%TMP%t,ind%SP%VS%B%TMP%dt
         write(un,*) 'solveBMethod,N_ind,N_cleanB = ',ind%SP%VS%B%SS%solve_method,&
         ind%SP%VS%B%ISP%iter_max,ind%SP%VS%phi%ISP%iter_max
         write(un,*) 'tol_ind,tol_cleanB = ',ind%SP%VS%B%ISP%tol_rel,ind%SP%VS%phi%ISP%tol_rel
         write(un,*) 'nstep,ME = ',ind%SP%VS%B%TMP%n_step,get_data(ind%ME(1))
         ! call displayPhysicalMinMax(ind%dB0dt,'dB0dt',un)
         ! call displayPhysicalMinMax(ind%B0,'B0',un)
         call displayPhysicalMinMax(ind%divB,'divB',un)
         call displayPhysicalMinMax(ind%divJ,'divJ',un)
         write(un,*) ''
         call display(ind%m,un)
       end subroutine

       subroutine print_induction(ind)
         implicit none
         type(induction),intent(in) :: ind
         call display(ind,6)
       end subroutine

       subroutine export_induction(ind,DT)
         implicit none
         type(induction),intent(in) :: ind
         type(dir_tree),intent(in) :: DT
         if (.not.ind%SP%EL%export_soln_only) then
           call export(ind%B      ,str(DT%B%restart),'B')
           call export(ind%Bnm1   ,str(DT%B%restart),'Bnm1')
           call export(ind%B0     ,str(DT%B%restart),'B0')
           call export(ind%J      ,str(DT%J%restart),'J')
           call export(ind%U_E%x  ,str(DT%B%restart),'U_E_x')
           call export(ind%U_E%y  ,str(DT%B%restart),'U_E_y')
           call export(ind%U_E%z  ,str(DT%B%restart),'U_E_z')
         endif
       end subroutine

       subroutine import_induction(ind,DT)
         implicit none
         type(induction),intent(inout) :: ind
         type(dir_tree),intent(in) :: DT
         if (.not.ind%SP%EL%export_soln_only) then
           call import(ind%B      ,str(DT%B%restart),'B')
           call import(ind%Bnm1   ,str(DT%B%restart),'Bnm1')
           call import(ind%B0     ,str(DT%B%restart),'B0')
           call import(ind%J      ,str(DT%J%restart),'J')
           call import(ind%U_E%x  ,str(DT%B%restart),'U_E_x')
           call import(ind%U_E%y  ,str(DT%B%restart),'U_E_y')
           call import(ind%U_E%z  ,str(DT%B%restart),'U_E_z')
         endif
       end subroutine

       ! **********************************************************
       ! **********************************************************
       ! **********************************************************

       subroutine export_tec_induction(ind,DT)
         implicit none
         type(induction),intent(inout) :: ind
         type(dir_tree),intent(in) :: DT
         if (ind%SP%VS%B%SS%restart.and.(.not.ind%SP%VS%B%SS%solve)) then
           ! This preserves the initial data
         else
           if (ind%SP%VS%B%SS%solve) then
             write(*,*) 'export_tec_induction at n_step = ',ind%SP%VS%B%TMP%n_step
             call export_processed(ind%m,ind%B,str(DT%B%field),'B',1)
             call export_processed(ind%m,ind%B0,str(DT%B%field),'B0',1)
             call export_processed(ind%m,ind%phi ,str(DT%phi%field),'phi',1)
             call export_processed(ind%m,ind%J ,str(DT%J%field),'J',1)
             call export_raw(ind%m,ind%divB ,str(DT%B%field),'divB',0)

             if (.not.ind%SP%EL%export_soln_only) then
             if (ind%SP%EL%export_symmetric) then
             call export_processed(ind%m,ind%B,str(DT%B%field),'B',1,anti_mirror(ind%SP%MP))
             call export_processed(ind%m,ind%J,str(DT%J%field),'J',1,ind%SP%MP)
             endif

             call export_raw(ind%m,ind%B,str(DT%B%restart),'B',0)
             call export_raw(ind%m,ind%Bnm1,str(DT%B%restart),'Bnm1',0)
             call export_raw(ind%m,ind%B0,str(DT%B%restart),'B0',0)
             call export_raw(ind%m,ind%F,str(DT%B%restart),'F',0)
             call export_raw(ind%m,ind%Fnm1,str(DT%B%restart),'Fnm1',0)
             call export_raw(ind%m,ind%Bstar,str(DT%B%restart),'Bstar',0)
             call export_raw(ind%m,ind%phi,str(DT%phi%restart),'phi',0)
             call export_raw(ind%m,ind%J,str(DT%J%restart),'J',0)
             call export_raw(ind%m,ind%U_E%x  ,str(DT%B%restart),'U_E_x',0)
             call export_raw(ind%m,ind%U_E%y  ,str(DT%B%restart),'U_E_y',0)
             call export_raw(ind%m,ind%U_E%z  ,str(DT%B%restart),'U_E_z',0)
             endif
             write(*,*) '     finished'
           endif
         endif
       end subroutine

       subroutine export_unsteady_0D_ind(ind,TMP)
         implicit none
         type(induction),intent(inout) :: ind
         type(time_marching_params),intent(in) :: TMP
         real(cp) :: temp,scale
         call compute_divBJ(ind%divB,ind%divJ,ind%B,ind%J,ind%m)
         call Ln(temp,ind%divB,2.0_cp,ind%m); call export(ind%probe_divB,TMP,temp)
         call Ln(temp,ind%divJ,2.0_cp,ind%m); call export(ind%probe_divJ,TMP,temp)
         if (ind%SP%IT%unsteady_B0%add) then
           call export(ind%probe_dB0dt(1),TMP,ind%dB0dt%x%BF(1)%GF%f(1,1,1))
           call export(ind%probe_dB0dt(2),TMP,ind%dB0dt%y%BF(1)%GF%f(1,1,1))
           call export(ind%probe_dB0dt(3),TMP,ind%dB0dt%z%BF(1)%GF%f(1,1,1))
           call export(ind%probe_B0(1),TMP,ind%B0%x%BF(1)%GF%f(1,1,1))
           call export(ind%probe_B0(2),TMP,ind%B0%y%BF(1)%GF%f(1,1,1))
           call export(ind%probe_B0(3),TMP,ind%B0%z%BF(1)%GF%f(1,1,1))
         endif

         scale = ind%SP%DP%ME_scale
         call add(ind%temp_F1,ind%B,ind%B0)
         call face2cellCenter(ind%temp_CC_VF,ind%temp_F1,ind%m)
         call compute_Total_Energy(ind%ME(1),ind%temp_CC_VF,TMP,ind%m,scale)
         call compute_Total_Energy_Domain(ind%ME_fluid(1),ind%temp_CC_VF,ind%CC_VF_fluid,TMP,ind%m,scale,ind%MD_fluid)
         call compute_Total_Energy_Domain(ind%ME_conductor(1),ind%temp_CC_VF,ind%CC_VF_sigma,TMP,ind%m,scale,ind%MD_sigma)
         call face2cellCenter(ind%temp_CC_VF,ind%B0,ind%m)
         call compute_Total_Energy(ind%ME(2),ind%temp_CC_VF,TMP,ind%m,scale)
         call compute_Total_Energy_Domain(ind%ME_fluid(2),ind%temp_CC_VF,ind%CC_VF_fluid,TMP,ind%m,scale,ind%MD_fluid)
         call compute_Total_Energy_Domain(ind%ME_conductor(2),ind%temp_CC_VF,ind%CC_VF_sigma,TMP,ind%m,scale,ind%MD_sigma)
         call face2cellCenter(ind%temp_CC_VF,ind%B,ind%m)
         call compute_Total_Energy(ind%ME(3),ind%temp_CC_VF,TMP,ind%m,scale)
         call compute_Total_Energy_Domain(ind%ME_fluid(3),ind%temp_CC_VF,ind%CC_VF_fluid,TMP,ind%m,scale,ind%MD_fluid)
         call compute_Total_Energy_Domain(ind%ME_conductor(3),ind%temp_CC_VF,ind%CC_VF_sigma,TMP,ind%m,scale,ind%MD_sigma)

         scale = ind%SP%DP%JE_scale
         call edge2cellCenter(ind%temp_CC_VF,ind%J,ind%m,ind%temp_F1)
         call compute_Total_Energy(ind%JE,ind%temp_CC_VF,TMP,ind%m,scale)
         call compute_Total_Energy_Domain(ind%JE_fluid,ind%temp_CC_VF,ind%CC_VF_fluid,TMP,ind%m,scale,ind%MD_fluid)
       end subroutine

       subroutine export_unsteady_1D_ind(ind,TMP,DT)
         implicit none
         type(induction),intent(inout) :: ind
         type(time_marching_params),intent(in) :: TMP
         type(dir_tree),intent(in) :: DT
         call export_processed(ind%m,ind%B,str(DT%B%unsteady),'B',1,TMP,ind%SP%VS%B%unsteady_lines)
         call export_processed(ind%m,ind%J,str(DT%J%unsteady),'J',1,TMP,ind%SP%VS%B%unsteady_lines)
       end subroutine

       subroutine export_unsteady_2D_ind(ind,TMP,DT)
         implicit none
         type(induction),intent(inout) :: ind
         type(time_marching_params),intent(inout) :: TMP
         type(dir_tree),intent(in) :: DT
         call export_processed(ind%m,ind%B,str(DT%B%unsteady),'B',1,TMP,ind%SP%VS%B%unsteady_planes)
         call export_processed(ind%m,ind%J,str(DT%J%unsteady),'J',1,TMP,ind%SP%VS%B%unsteady_planes)
       end subroutine

       subroutine export_unsteady_3D_ind(ind,TMP,DT)
         implicit none
         type(induction),intent(inout) :: ind
         type(time_marching_params),intent(in) :: TMP
         type(dir_tree),intent(in) :: DT
         call export_processed(ind%m,ind%B,str(DT%B%unsteady),'B',1,TMP,ind%SP%VS%B%unsteady_field)
         call export_processed(ind%m,ind%J,str(DT%J%unsteady),'J',1,TMP,ind%SP%VS%B%unsteady_field)
       end subroutine

       subroutine compute_J_ind(ind)
         implicit none
         type(induction),intent(inout) :: ind
         ! call assign(ind%J,0.0_cp)
         ! call embedEdge(ind%J,ind%J_interior,ind%MD_sigma)
         call compute_J(ind%J,ind%B,ind%SP%IT%current%scale,ind%m)
       end subroutine

       subroutine set_sigma_inv_ind(ind)
         implicit none
         type(induction),intent(inout) :: ind
         call set_sigma_inv_VF(ind%sigmaInv_edge,ind%m,ind%MD_sigma,ind%SP%DP)
       end subroutine

       subroutine init_matrix_based_ops_ind(ind)
         implicit none
         type(induction),intent(inout) :: ind
         real(cp),dimension(2) :: diffusion_treatment
         ! diffusion_treatment = (/1.0_cp,0.0_cp/) ! No treatment to curl-curl operator
         diffusion_treatment = (/-ind%SP%VS%B%MFP%coeff_implicit,1.0_cp/)    ! likely broken
         ! diffusion_treatment = (/ind%SP%VS%B%MFP%coeff_implicit,1.0_cp/)    ! likely broken
         call init_curl_curl(ind%m,ind%sigmaInv_edge)
         call init_Laplacian_SF(ind%m)
         call multiply_curl_curl(ind%m,diffusion_treatment(1))
         call add_curl_curl(ind%m,diffusion_treatment(2))
       end subroutine

       subroutine solve_induction(ind,F,Fnm1,TMP,EF,EN,DT)
         implicit none
         type(induction),intent(inout) :: ind
         type(VF),intent(in) :: F,Fnm1
         type(time_marching_params),intent(inout) :: TMP
         type(export_frequency),intent(in) :: EF
         type(export_now),intent(in) :: EN
         type(dir_tree),intent(in) :: DT
         integer :: i

         do i=1,ind%SP%VS%B%TMP%multistep_iter
         select case (ind%SP%VS%B%SS%solve_method)
         case (1)
           call Euler_time_no_diff_Euler_sources_no_correction(ind%B,ind%Bstar,F,TMP)
         case (2)
           call Euler_time_no_diff_AB2_sources_no_correction(ind%B,ind%Bstar,F,Fnm1,TMP)
         case (3)
           call Euler_time_no_diff_Euler_sources(ind%PCG_cleanB,ind%B,ind%Bstar,&
           ind%Bnm1,ind%phi,F,ind%m,TMP,ind%temp_F2,ind%temp_CC,EF%unsteady_0D%export_now)
         case (4)
          call Euler_time_no_diff_AB2_sources(ind%PCG_cleanB,ind%B,ind%Bstar,&
           ind%Bnm1,ind%phi,F,Fnm1,ind%m,TMP,ind%temp_F1,ind%temp_CC,&
           EF%unsteady_0D%export_now)
         case (5)
           call Euler_time_Euler_sources(ind%PCG_B,ind%PCG_cleanB,ind%B,ind%Bstar,ind%Bnm1,&
           ind%phi,F,ind%m,TMP,ind%temp_F1,ind%temp_E,ind%temp_CC,&
           EF%unsteady_0D%export_now)
         case (6)
           call Euler_time_AB2_sources(ind%PCG_B,ind%PCG_cleanB,ind%B,ind%Bstar,ind%Bnm1,&
           ind%phi,F,Fnm1,ind%m,TMP,ind%temp_F1,ind%temp_E,ind%temp_CC,&
           EF%unsteady_0D%export_now)
         case (7)
           call O2_BDF_time_AB2_sources(ind%PCG_B,ind%PCG_cleanB,ind%B,ind%Bstar,&
           ind%Bnm1,ind%phi,F,Fnm1,ind%m,TMP,ind%temp_F1,ind%temp_E,ind%temp_CC,&
           EF%unsteady_0D%export_now)
         case default; stop 'Error: bad solveBMethod input solve_induction in induction.f90'
         end select
         call iterate_step(TMP)
         if (ind%SP%embed_B_interior) call embedFace(ind%B,ind%B_interior,ind%MD_sigma)
         enddo

         call compute_J_ind(ind)

         ! ********************* POST SOLUTION PRINT/EXPORT *********************

         if (EF%unsteady_0D%export_now) call export_unsteady_0D(ind,TMP)
         if (EF%unsteady_1D%export_now) call export_unsteady_1D(ind,TMP,DT)
         if (EF%unsteady_2D%export_now) call export_unsteady_2D(ind,TMP,DT)
         if (EF%unsteady_3D%export_now) call export_unsteady_3D(ind,TMP,DT)
         if (EF%info%export_now) call print(ind)

         if (EF%final_solution%export_now.or.EN%B%this.or.EN%all%this) then
           ! call export(ind,DT)
           call export_tec(ind,DT)
         endif
       end subroutine

       subroutine compute_export_E_M_budget(ind,U,DT)
         implicit none
         type(induction),intent(inout) :: ind
         type(VF),intent(in) :: U
         type(dir_tree),intent(in) :: DT
         call E_M_Budget_wrapper(DT,U,ind%B,ind%Bnm1,ind%B0,ind%B0,ind%J,ind%m,&
         ind%MD_fluid,ind%MD_sigma,ind%SP%DP,ind%SP%VS%B%TMP,ind%SP%MP)
       end subroutine

       end module