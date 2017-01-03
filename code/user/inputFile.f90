       module inputFile_mod
       use current_precision_mod
       use string_mod
       use path_mod
       use dir_tree_mod
       use sim_params_mod
       use IO_tools_mod
       use iter_solver_params_mod
       use time_marching_params_mod
       implicit none
       private
       public :: readInputFile

       contains

       subroutine readInputFile(SP,DT,Re,Ha,Gr,Fr,Pr,Ec,Rem,&
         coupled,TMP_U,TMP_B,TMP_T,ISP_U,ISP_B,ISP_T,ISP_P,ISP_phi,&
         tw,sig_local_over_sig_f)
         implicit none
         type(sim_params),intent(in) :: SP
         type(dir_tree),intent(in) :: DT
         type(iter_solver_params),intent(inout) :: ISP_U,ISP_B,ISP_T,ISP_P,ISP_phi
         type(time_marching_params),intent(inout) :: coupled,TMP_U,TMP_B,TMP_T
         real(cp),intent(inout) :: Re,Ha,Gr,Fr,Pr,Ec,Rem,tw,sig_local_over_sig_f
         real(cp) :: time,dtime
         ! ***************** DEFAULT VALUES *****************
         Re         = 4.0_cp*pow(2)
         Ha         = 1.0_cp*pow(2)
         Rem        = 1.0_cp*pow(0)
         tw         = 0.5_cp
         sig_local_over_sig_f = pow(-3)
         Gr         = 0.0_cp
         Pr         = 0.01_cp
         Fr         = 1.0_cp
         Ec         = 0.0_cp

         ! call init(ISP,iter_max,tol_rel,tol_abs,n_skip_check_res)
         ! call init(ISP_B  , 10000, pow(-5),  pow(-7) , 100, str(DT%ISP),'ISP_B')
         call init(ISP_B  ,10000 , pow(-5),  pow(-7) , 100, str(DT%ISP),'ISP_B')
         call init(ISP_U  ,  40  , pow(-10), pow(-13), 100, str(DT%ISP),'ISP_U')
         call init(ISP_T  ,   5  , pow(-10), pow(-13), 100, str(DT%ISP),'ISP_T')

         call init(ISP_p  ,   5  , pow(-10), pow(-13), 100, str(DT%ISP),'ISP_p')
         call init(ISP_phi,   5  , pow(-10), pow(-13), 100, str(DT%ISP),'ISP_phi')

         ! BMC 102
         time  = 100.0_cp
         ! time  = 200.0_cp
         ! dtime = 1.0_cp*10.0_cp**(-3.0_cp)
         ! dtime = 1.0_cp*10.0_cp**(-2.0_cp)
         ! dtime = 1.0_cp*pow(-4)
         dtime = 2.0_cp*pow(-4)
         ! dtime = 8.0_cp*pow(-4)
         ! dtime = 1.0_cp*pow(-5)
         ! dtime = 1.0_cp*pow(-4)*4.0**(2.0_cp)

         ! time  = 100.0_cp
         ! dtime = 1.0_cp*10.0_cp**(-4.0_cp)
         ! dtime = 5.0_cp*10.0_cp**(-6.0_cp)
         ! dtime = get_dt_NME(21)

         ! dtime = 1.0_cp*10.0_cp**(-5.0_cp)*Rem*sig_local_over_sig_f ! Explicit time marching estimate

         ! call init(TMP,n_step_stop,dtime,dir,name)
         call init(coupled,ceiling(time/dtime,li),dtime,str(DT%TMP), 'TMP_coupled')
         ! call init(coupled,1000000000,dtime,str(DT%TMP), 'TMP_coupled')

         call init(TMP_B, coupled%n_step_stop, coupled%dt/pow(2), str(DT%TMP), 'TMP_B')
         ! call init(TMP_B, coupled%n_step_stop, coupled%dt, str(DT%TMP), 'TMP_B')
         call init(TMP_U, coupled%n_step_stop, coupled%dt, str(DT%TMP), 'TMP_U')
         call init(TMP_T, coupled%n_step_stop, coupled%dt, str(DT%TMP), 'TMP_T')

         if (coupled%n_step_stop.lt.1) stop 'Error: coupled%n_step_stop<1 in inputFile.f90'

         if (SP%coupled_time_step) then
           call couple_time_step(TMP_U,coupled)
           call couple_time_step(TMP_B,coupled)
           call couple_time_step(TMP_T,coupled)
         endif
         ! Stopping criteria for iterative solvers:
         !         ||Ax - b||
         !         ----------- < tol_rel
         !         ||Ax⁰ - b||
         ! NOTE: tol_rel must be > 10^(-10)
         ! for the PPE, div(u) -> 0 as t-> infinity.
         ! Which means b and r⁰ -> 0 as t-> infinity.
         if (SP%BMC%VS%U%SS%restart)      call import(TMP_U)
         if (.not.SP%BMC%VS%U%SS%restart) call export(TMP_U)
         if (SP%BMC%VS%U%SS%restart)      call import(ISP_U)
         if (.not.SP%BMC%VS%U%SS%restart) call export(ISP_U)
         if (SP%BMC%VS%U%SS%restart)      call import(ISP_P)
         if (.not.SP%BMC%VS%U%SS%restart) call export(ISP_P)

         if (SP%BMC%VS%B%SS%restart)      call import(TMP_B)
         if (.not.SP%BMC%VS%B%SS%restart) call export(TMP_B)
         if (SP%BMC%VS%B%SS%restart)      call import(ISP_B)
         if (.not.SP%BMC%VS%B%SS%restart) call export(ISP_B)
         if (SP%BMC%VS%B%SS%restart)      call import(ISP_phi)
         if (.not.SP%BMC%VS%B%SS%restart) call export(ISP_phi)

         if (SP%BMC%VS%T%SS%restart)      call import(TMP_T)
         if (.not.SP%BMC%VS%T%SS%restart) call export(TMP_T)
         if (SP%BMC%VS%T%SS%restart)      call import(ISP_T)
         if (.not.SP%BMC%VS%T%SS%restart) call export(ISP_T)
       end subroutine

       end module