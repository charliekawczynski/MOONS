       module ops_embedExtract_mod
       ! Not all embed / extract routines are used for each method. For example,
       ! the CT method only uses embedEdge, and not embedCC or embedFace.

       use grid_mod
       use vectorField_mod
       use ops_aux_mod

       implicit none

       private

#ifdef _SINGLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(8)
#endif
#ifdef _DOUBLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(14)
#endif
#ifdef _QUAD_PRECISION_
       integer,parameter :: cp = selected_real_kind(32)
#endif

       public :: init,subdomain

       public :: extractFace
       public :: embedFace
       public :: embedEdge
       public :: embedCC
       public :: embedN

       ! public :: embedEdgeExclude,embedEdgeInclude,embedEdgeIncludeDir
       ! public :: embedCCExclude,embedCCInclude,embedCCDir

       interface init;   module procedure initSubdomain;   end interface

       type subdomain
         integer,dimension(3) :: N
         integer,dimension(3) :: Nin1
         integer,dimension(3) :: Nin2
         integer,dimension(3) :: Nice1
         integer,dimension(3) :: Nice2
         integer,dimension(3) :: Nici1
         integer,dimension(3) :: Nici2
       end type

       contains

       subroutine initSubdomain(SD,Ni,Nwtop,Nwbot)
         implicit none
         type(subdomain),intent(inout) :: SD
         integer,dimension(3),intent(in) :: Ni,Nwtop,Nwbot
         ! The INDEX OF CELLS section should not be modified.
         SD%N     = Ni+Nwtop+Nwbot
         SD%Nin1  = Nwbot+2
         SD%Nin2  = SD%N-Nwtop+2
         SD%Nice1 = Nwbot+2
         SD%Nice2 = SD%N-Nwtop+1
         SD%Nici1 = Nwbot+1
         SD%Nici2 = SD%N-Nwtop+2
       end subroutine

       ! *********************************************************************************
       ! *********************************************************************************
       ! ***************************** INTERFACE ROUTINES ********************************
       ! *********************************************************************************
       ! *********************************************************************************

       ! *********************************************************************************
       ! ****************************** EXTRACT ROUTINES *********************************
       ! *********************************************************************************

       subroutine extractFace(face_i,face_t,SD,g)
         ! Although extractType = 2 is the most physical, some models may require
         ! other types, e.g. 2D flows with neumann / periodic BCs along a given
         ! direction. This warrents including fictitious cells to ensure no variations
         ! exist along a particular direction.
         implicit none
         type(vectorField),intent(inout) :: face_i
         type(vectorField),intent(in) :: face_t
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         ! call extractFaceInclude(face_i,face_t,SD,g)
         call extractFaceExclude(face_i,face_t,SD,g)
         ! call extractFaceIncludeDir(face_i,face_t,SD,g)
       end subroutine

       ! *********************************************************************************
       ! ******************************* EMBED ROUTINES **********************************
       ! *********************************************************************************

       subroutine embedEdge(edge_t,edge_i,SD,g)
         implicit none
         type(vectorField),intent(inout) :: edge_t
         type(vectorField),intent(in) :: edge_i
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         ! call embedEdgeInclude(edge_t,edge_i,SD,g)
         ! call embedEdgeExclude(edge_t,edge_i,SD,g)

         call embedEdgeIncludeDir(edge_t,edge_i,SD,g,1)
       end subroutine

       subroutine embedFace(face_t,face_i,SD,g)
         implicit none
         type(vectorField),intent(inout) :: face_t
         type(vectorField),intent(in) :: face_i
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         ! call embedFaceInclude(face_t,face_i,SD,g)
         ! call embedFaceExclude(edge_t,face_i,SD,g)
         call embedFaceIncludeDir(face_t,face_i,SD,g,1)
       end subroutine

       subroutine embedCC(CC_t,CC_i,SD,g)
         implicit none
         type(vectorField),intent(inout) :: CC_t
         type(vectorField),intent(in) :: CC_i
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         integer :: dir
         dir = 1
         call embedCCInclude(CC_t,CC_i,SD)
         call embedCCExclude(CC_t,CC_i,SD,g)
         call embedCCIncludeDir(CC_t,CC_i,SD,g,dir)
       end subroutine

       subroutine embedN(N_t,N_i,SD,g)
         implicit none
         type(vectorField),intent(inout) :: N_t
         type(vectorField),intent(in) :: N_i
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         integer,dimension(3) :: Nin1,Nin2
         Nin1  = SD%Nin1; Nin2  = SD%Nin2
         N_t%x(Nin1(1):Nin2(1),Nin1(2):Nin2(2),Nin1(3):Nin2(3)) = &
         N_i%x(2:g%c(1)%sn-1,2:g%c(2)%sn-1,2:g%c(3)%sn-1)
         N_t%y(Nin1(1):Nin2(1),Nin1(2):Nin2(2),Nin1(3):Nin2(3)) = &
         N_i%y(2:g%c(1)%sn-1,2:g%c(2)%sn-1,2:g%c(3)%sn-1)
         N_t%z(Nin1(1):Nin2(1),Nin1(2):Nin2(2),Nin1(3):Nin2(3)) = &
         N_i%z(2:g%c(1)%sn-1,2:g%c(2)%sn-1,2:g%c(3)%sn-1)
       end subroutine

       ! *********************************************************************************
       ! *********************************************************************************
       ! *************************** CASE SPECIFIC ROUTINES ******************************
       ! *********************************************************************************
       ! *********************************************************************************

       ! *********************************************************************************
       ! ****************************** EXTRACT ROUTINES *********************************
       ! *********************************************************************************

       subroutine extractFaceInclude(face_i,face_t,SD,g)
         ! Including ghost nodes / ghost cells / boundary values
         implicit none
         type(vectorField),intent(inout) :: face_i
         type(vectorField),intent(in) :: face_t
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         integer,dimension(3) :: Nin1,Nin2,Nici1,Nici2
         Nin1  = SD%Nin1; Nin2  = SD%Nin2; Nici1 = SD%Nici1; Nici2 = SD%Nici2
         face_i%x = face_t%x(Nin1(1)-1:Nin2(1)+1,Nici1(2)  :Nici2(2)  ,Nici1(3)  :Nici2(3)  )
         face_i%y = face_t%y(Nici1(1)  :Nici2(1)  ,Nin1(2)-1:Nin2(2)+1,Nici1(3)  :Nici2(3)  )
         face_i%z = face_t%z(Nici1(1)  :Nici2(1)  ,Nici1(2)  :Nici2(2)  ,Nin1(3)-1:Nin2(3)+1)
       end subroutine

       subroutine extractFaceExclude(face_i,face_t,SD,g)
         ! Excluding ghost nodes / ghost cells / boundary values
         implicit none
         type(vectorField),intent(inout) :: face_i
         type(vectorField),intent(in) :: face_t
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         integer,dimension(3) :: Nin1,Nin2,Nice1,Nice2,Nici1,Nici2
         Nin1  = SD%Nin1; Nin2  = SD%Nin2; Nice1 = SD%Nice1; Nice2 = SD%Nice2
         call zeroGhostPoints(face_i)
         face_i%x(2:g%c(1)%sn-1,2:g%c(2)%sc-1,2:g%c(3)%sc-1) = &
         face_t%x( Nin1(1): Nin2(1),Nice1(2):Nice2(2),Nice1(3):Nice2(3))
         face_i%y(2:g%c(1)%sc-1,2:g%c(2)%sn-1,2:g%c(3)%sc-1) = &
         face_t%y(Nice1(1):Nice2(1), Nin1(2): Nin2(2),Nice1(3):Nice2(3))
         face_i%z(2:g%c(1)%sc-1,2:g%c(2)%sc-1,2:g%c(3)%sn-1) = &
         face_t%z(Nice1(1):Nice2(1),Nice1(2):Nice2(2), Nin1(3): Nin2(3))
       end subroutine

       subroutine extractFaceIncludeDir(face_i,face_t,SD,g)
         ! ** Probably the most physically correct one **
         ! Excluding ghost nodes / ghost cells
         ! Including boundary values
         implicit none
         type(vectorField),intent(inout) :: face_i
         type(vectorField),intent(in) :: face_t
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         integer,dimension(3) :: Nin1,Nin2,Nice1,Nice2
         Nin1  = SD%Nin1; Nin2  = SD%Nin2; Nice1 = SD%Nice1; Nice2 = SD%Nice2

         call zeroGhostPoints(face_i)
         face_i%x(:,2:g%c(2)%sc-1,2:g%c(3)%sc-1) = &
         face_t%x( Nin1(1)-1: Nin2(1)+1,Nice1(2):Nice2(2),Nice1(3):Nice2(3))
         face_i%y(2:g%c(1)%sc-1,:,2:g%c(3)%sc-1) = &
         face_t%y(Nice1(1):Nice2(1), Nin1(2)-1: Nin2(2)+1,Nice1(3):Nice2(3))
         face_i%z(2:g%c(1)%sc-1,2:g%c(2)%sc-1,:) = &
         face_t%z(Nice1(1):Nice2(1),Nice1(2):Nice2(2), Nin1(3)-1: Nin2(3)+1)
       end subroutine

       ! *********************************************************************************
       ! ******************************* EMBED ROUTINES **********************************
       ! *********************************************************************************

       subroutine embedFaceInclude(face_t,face_i,SD,g) ! Not yet tested
         ! Include ghost cells (possibly for periodic BCs)
         implicit none
         type(vectorField),intent(inout) :: face_t
         type(vectorField),intent(in) :: face_i
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         integer,dimension(3) :: Nin1,Nin2,Nice1,Nice2,Nici1,Nici2
         Nin1  = SD%Nin1; Nin2  = SD%Nin2; Nici1 = SD%Nici1; Nici2 = SD%Nici2
         face_t%x( Nin1(1): Nin2(1),Nici1(2):Nici2(2),Nici1(3):Nici2(3)) = face_i%x(2:g%c(1)%sn-1,:,:)
         face_t%y(Nici1(1):Nici2(1), Nin1(2): Nin2(2),Nici1(3):Nici2(3)) = face_i%y(:,2:g%c(2)%sn-1,:)
         face_t%z(Nici1(1):Nici2(1),Nici1(2):Nici2(2), Nin1(3): Nin2(3)) = face_i%z(:,:,2:g%c(3)%sn-1)
       end subroutine

       subroutine embedFaceExclude(face_t,face_i,SD,g) ! Not yet tested
         ! Exclude wall boundary (the most physically likely case)
         implicit none
         type(vectorField),intent(inout) :: face_t
         type(vectorField),intent(in) :: face_i
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         integer,dimension(3) :: Nin1,Nin2,Nice1,Nice2
         Nin1  = SD%Nin1; Nin2  = SD%Nin2; Nice1 = SD%Nice1; Nice2 = SD%Nice2
         face_t%x(Nin1(1):Nin2(1),Nice1(2):Nice2(2),Nice1(3):Nice2(3)) = &
         face_i%x(2:g%c(1)%sn-1,2:g%c(2)%sc-1,2:g%c(3)%sc-1)
         face_t%y(Nice1(1):Nice2(1),Nin1(2):Nin2(2),Nice1(3):Nice2(3)) = &
         face_i%y(2:g%c(1)%sc-1,2:g%c(2)%sn-1,2:g%c(3)%sc-1)
         face_t%z(Nice1(1):Nice2(1),Nice1(2):Nice2(2),Nin1(3):Nin2(3)) = &
         face_i%z(2:g%c(1)%sc-1,2:g%c(2)%sc-1,2:g%c(3)%sn-1)
       end subroutine

       subroutine embedFaceIncludeDir(face_t,face_i,SD,g,dir) ! Not yet tested
         ! Exclude wall boundary (the most physically likely case)
         implicit none
         type(vectorField),intent(inout) :: face_t
         type(vectorField),intent(in) :: face_i
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         integer,intent(in) :: dir
         integer,dimension(3) :: Nin1,Nin2,Nice1,Nice2,Nici1,Nici2
         Nin1  = SD%Nin1; Nin2  = SD%Nin2; Nice1 = SD%Nice1
         Nice2 = SD%Nice2; Nici1 = SD%Nici1; Nici2 = SD%Nici2
         select case (dir)
         case (1); face_t%x(Nin1(1):Nin2(1),Nice1(2):Nice2(2),Nice1(3):Nice2(3)) = &
                   face_i%x(2:g%c(1)%sn-1,2:g%c(2)%sc-1,2:g%c(3)%sc-1)
                   face_t%y(Nici1(1):Nici2(1),Nin1(2):Nin2(2),Nice1(3):Nice2(3)) = &
                   face_i%y(:,2:g%c(2)%sc-1,2:g%c(3)%sc-1)
                   face_t%z(Nici1(1):Nici2(1),Nice1(2):Nice2(2),Nin1(3):Nin2(3)) = &
                   face_i%z(:,2:g%c(2)%sc-1,2:g%c(3)%sn-1)
         case (2); face_t%x(Nin1(1):Nin2(1),Nici1(2):Nici2(2),Nice1(3):Nice2(3)) = &
                   face_i%x(2:g%c(1)%sn-1,:,2:g%c(3)%sc-1)
                   face_t%y(Nice1(1):Nice2(1),Nin1(2):Nin2(2),Nice1(3):Nice2(3)) = &
                   face_i%y(2:g%c(1)%sc-1,2:g%c(2)%sn-1,2:g%c(3)%sc-1)
                   face_t%z(Nice1(1):Nice2(1),Nici1(2):Nici2(2),Nin1(3):Nin2(3)) = &
                   face_i%z(2:g%c(1)%sc-1,:,2:g%c(3)%sn-1)
         case (3); face_t%x(Nin1(1):Nin2(1),Nice1(2):Nice2(2),Nici1(3):Nici2(3)) = &
                   face_i%x(2:g%c(1)%sn-1,2:g%c(2)%sc-1,:)
                   face_t%y(Nice1(1):Nice2(1),Nin1(2):Nin2(2),Nici1(3):Nici2(3)) = &
                   face_i%y(2:g%c(1)%sc-1,2:g%c(2)%sn-1,:)
                   face_t%z(Nice1(1):Nice2(1),Nice1(2):Nice2(2),Nin1(3):Nin2(3)) = &
                   face_i%z(2:g%c(1)%sc-1,2:g%c(2)%sc-1,2:g%c(3)%sn-1)
         case default
         stop 'Error: dir must = 1,2,3 in embedFaceIncludeDir in ops_embedExtract.f90'
         end select
       end subroutine

       subroutine embedEdgeInclude(edge_t,edge_i,SD,g)
         implicit none
         type(vectorField),intent(inout) :: edge_t
         type(vectorField),intent(in) :: edge_i
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         integer,dimension(3) :: Nin1,Nin2,Nici1,Nici2
         Nin1  = SD%Nin1; Nin2  = SD%Nin2; Nici1 = SD%Nici1; Nici2 = SD%Nici2
         edge_t%x(Nici1(1):Nici2(1),Nin1(2):Nin2(2),Nin1(3):Nin2(3)) = &
         edge_i%x(:,2:g%c(2)%sn-1,2:g%c(3)%sn-1)
         edge_t%y(Nin1(1):Nin2(1),Nici1(2):Nici2(2),Nin1(3):Nin2(3)) = &
         edge_i%y(2:g%c(1)%sn-1,:,2:g%c(3)%sn-1)
         edge_t%z(Nin1(1):Nin2(1),Nin1(2):Nin2(2),Nici1(3):Nici2(3)) = &
         edge_i%z(2:g%c(1)%sn-1,2:g%c(2)%sn-1,:)
       end subroutine

       subroutine embedEdgeExclude(edge_t,edge_i,SD,g)
         implicit none
         type(vectorField),intent(inout) :: edge_t
         type(vectorField),intent(in) :: edge_i
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         integer,dimension(3) :: Nin1,Nin2,Nice1,Nice2
         Nin1  = SD%Nin1; Nin2  = SD%Nin2; Nice1 = SD%Nice1; Nice2 = SD%Nice2
         edge_t%x(Nice1(1):Nice2(1),Nin1(2):Nin2(2),Nin1(3):Nin2(3)) = &
         edge_i%x(2:g%c(1)%sc-1,2:g%c(2)%sn-1,2:g%c(3)%sn-1)
         edge_t%y(Nin1(1):Nin2(1),Nice1(2):Nice2(2),Nin1(3):Nin2(3)) = &
         edge_i%y(2:g%c(1)%sn-1,2:g%c(2)%sc-1,2:g%c(3)%sn-1)
         edge_t%z(Nin1(1):Nin2(1),Nin1(2):Nin2(2),Nice1(3):Nice2(3)) = &
         edge_i%z(2:g%c(1)%sn-1,2:g%c(2)%sn-1,2:g%c(3)%sc-1)
       end subroutine

       subroutine embedEdgeIncludeDir(edge_t,edge_i,SD,g,dir)
         implicit none
         type(vectorField),intent(inout) :: edge_t
         type(vectorField),intent(in) :: edge_i
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         integer,intent(in) :: dir
         integer,dimension(3) :: Nin1,Nin2,Nice1,Nice2,Nici1,Nici2
         Nin1  = SD%Nin1; Nin2  = SD%Nin2; Nice1 = SD%Nice1
         Nice2 = SD%Nice2; Nici1 = SD%Nici1; Nici2 = SD%Nici2
         select case(dir)
         case (1);edge_t%x(Nici1(1):Nici2(1),Nin1(2):Nin2(2),Nin1(3):Nin2(3)) = &
                  edge_i%x(:,2:g%c(2)%sn-1,2:g%c(3)%sn-1)
                  edge_t%y(Nin1(1)-1:Nin2(1)+1,Nice1(2):Nice2(2),Nin1(3):Nin2(3)) = &
                  edge_i%y(:,2:g%c(2)%sc-1,2:g%c(3)%sn-1)
                  edge_t%z(Nin1(1)-1:Nin2(1)+1,Nin1(2):Nin2(2),Nice1(3):Nice2(3)) = &
                  edge_i%z(:,2:g%c(2)%sn-1,2:g%c(3)%sc-1)
         case (2);edge_t%x(Nice1(1):Nice2(1),Nin1(2)-1:Nin2(2)+1,Nin1(3):Nin2(3)) = &
                  edge_i%x(2:g%c(1)%sc-1,:,2:g%c(3)%sn-1)
                  edge_t%y(Nin1(1):Nin2(1),Nici1(2):Nici2(2),Nin1(3):Nin2(3)) = &
                  edge_i%y(2:g%c(1)%sn-1,:,2:g%c(3)%sn-1)
                  edge_t%z(Nin1(1):Nin2(1),Nin1(2)-1:Nin2(2)+1,Nice1(3):Nice2(3)) = &
                  edge_i%z(2:g%c(1)%sn-1,:,2:g%c(3)%sc-1)
         case (3);edge_t%x(Nice1(1):Nice2(1),Nin1(2):Nin2(2),Nin1(3)-1:Nin2(3)+1) = &
                  edge_i%x(2:g%c(1)%sc-1,2:g%c(2)%sn-1,:)
                  edge_t%y(Nin1(1):Nin2(1),Nice1(2):Nice2(2),Nin1(3)-1:Nin2(3)+1) = &
                  edge_i%y(2:g%c(1)%sn-1,2:g%c(2)%sc-1,:)
                  edge_t%z(Nin1(1):Nin2(1),Nin1(2):Nin2(2),Nici1(3):Nici2(3)) = &
                  edge_i%z(2:g%c(1)%sn-1,2:g%c(2)%sn-1,:)
         case default
         stop 'Error: dir must = 1,2,3 in embedEdgeDir in ops_embedExtract.f90'
         end select
       end subroutine

       subroutine embedCCInclude(CC_t,CC_i,SD)
         implicit none
         type(vectorField),intent(inout) :: CC_t
         type(vectorField),intent(in) :: CC_i
         type(subdomain),intent(in) :: SD
         integer,dimension(3) :: Nici1,Nici2
         Nici1 = SD%Nici1; Nici2 = SD%Nici2
         CC_t%x(Nici1(1):Nici2(1),Nici1(2):Nici2(2),Nici1(3):Nici2(3)) = CC_i%x
         CC_t%y(Nici1(1):Nici2(1),Nici1(2):Nici2(2),Nici1(3):Nici2(3)) = CC_i%y
         CC_t%z(Nici1(1):Nici2(1),Nici1(2):Nici2(2),Nici1(3):Nici2(3)) = CC_i%z
       end subroutine

       subroutine embedCCExclude(CC_t,CC_i,SD,g)
         implicit none
         type(vectorField),intent(inout) :: CC_t
         type(vectorField),intent(in) :: CC_i
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         integer,dimension(3) :: Nice1,Nice2
         Nice1 = SD%Nice1; Nice2 = SD%Nice2
         CC_t%x(Nice1(1):Nice2(1),Nice1(2):Nice2(2),Nice1(3):Nice2(3)) = &
         CC_i%x(2:g%c(1)%sc-1,2:g%c(2)%sc-1,2:g%c(3)%sc-1)
         CC_t%y(Nice1(1):Nice2(1),Nice1(2):Nice2(2),Nice1(3):Nice2(3)) = &
         CC_i%y(2:g%c(1)%sc-1,2:g%c(2)%sc-1,2:g%c(3)%sc-1)
         CC_t%z(Nice1(1):Nice2(1),Nice1(2):Nice2(2),Nice1(3):Nice2(3)) = &
         CC_i%z(2:g%c(1)%sc-1,2:g%c(2)%sc-1,2:g%c(3)%sc-1)
       end subroutine

       subroutine embedCCIncludeDir(CC_t,CC_i,SD,g,dir)
         implicit none
         type(vectorField),intent(inout) :: CC_t
         type(vectorField),intent(in) :: CC_i
         type(subdomain),intent(in) :: SD
         type(grid),intent(in) :: g
         integer,intent(in) :: dir
         integer,dimension(3) :: Nice1,Nice2,Nici1,Nici2
         Nice1 = SD%Nice1; Nice2 = SD%Nice2; Nici1 = SD%Nici1; Nici2 = SD%Nici2
         select case (dir)
         case (1); CC_t%x(Nici1(1):Nici2(1),Nice1(2):Nice2(2),Nice1(3):Nice2(3)) = &
                   CC_i%x(:,2:g%c(2)%sc-1,2:g%c(3)%sc-1)
                   CC_t%y(Nici1(1):Nici2(1),Nice1(2):Nice2(2),Nice1(3):Nice2(3)) = &
                   CC_i%y(:,2:g%c(2)%sc-1,2:g%c(3)%sc-1)
                   CC_t%z(Nici1(1):Nici2(1),Nice1(2):Nice2(2),Nice1(3):Nice2(3)) = &
                   CC_i%z(:,2:g%c(2)%sc-1,2:g%c(3)%sc-1)
         case (2); CC_t%x(Nice1(1):Nice2(1),Nici1(2):Nici2(2),Nice1(3):Nice2(3)) = &
                   CC_i%x(2:g%c(1)%sc-1,:,2:g%c(3)%sc-1)
                   CC_t%y(Nice1(1):Nice2(1),Nici1(2):Nici2(2),Nice1(3):Nice2(3)) = &
                   CC_i%y(2:g%c(1)%sc-1,:,2:g%c(3)%sc-1)
                   CC_t%z(Nice1(1):Nice2(1),Nici1(2):Nici2(2),Nice1(3):Nice2(3)) = &
                   CC_i%z(2:g%c(1)%sc-1,:,2:g%c(3)%sc-1)
         case (3); CC_t%x(Nice1(1):Nice2(1),Nice1(2):Nice2(2),Nici1(3):Nici2(3)) = &
                   CC_i%x(2:g%c(1)%sc-1,2:g%c(2)%sc-1,:)
                   CC_t%y(Nice1(1):Nice2(1),Nice1(2):Nice2(2),Nici1(3):Nici2(3)) = &
                   CC_i%y(2:g%c(1)%sc-1,2:g%c(2)%sc-1,:)
                   CC_t%z(Nice1(1):Nice2(1),Nice1(2):Nice2(2),Nici1(3):Nici2(3)) = &
                   CC_i%z(2:g%c(1)%sc-1,2:g%c(2)%sc-1,:)
         case default
         stop 'Error: dir must = 1,2,3 in embedCCIncludeDir in ops_embedExtract.f90'
         end select
       end subroutine

       ! *********************************************************************************
       ! *********************************************************************************
       ! ******************************* VECTOR ROUTINES *********************************
       ! *********************************************************************************
       ! *********************************************************************************

       end module