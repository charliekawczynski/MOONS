       module ops_interp_mod
       ! Directions are frequently used in this code. 
       ! For clarity, some diagrams here show how the 
       ! directions are defined.
       ! 
       ! faceDir = 1 (x)
       ! 
       !                       z
       !                y      |
       !                 \   __|____
       !                  \ |\ |     \
       !                   \| \|______\
       !      faceDir --->  \  |      |
       !                     \ |      |
       !                      \|______|_____ x
       ! 
       ! 
       ! 
       ! edgeDir = 1 (x)
       ! 
       !                       z
       !                y      |
       !                 \   __|____
       !                  \ |\ |     \
       !                   \| \|______\
       !                    \  |      |
       !                     \ |      |
       !                      \|______|_____ x
       !                        -------> edgeDir
       ! 
       use grid_mod
       use SF_mod
       use VF_mod
       implicit none

       ! Compiler flags: ( fopenmp, _DEBUG_INTERP_ )

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

       ! ------------------------------- POSSIBLE ALIASES ---------------------------------
       ! public :: F2F,F2N,F2CC,F2E,CC2F,CC2E,CC2N,E2F,E2N,E2CC,N2F,N2E

       ! ------------------------------- INTERPOLATION ROUTINES ---------------------------------
       ! Base interpolation
       public :: interp               ! call interp(f,g,gd,dir)

       ! Derived interpolations
       public :: face2Face            ! call face2Face(faceAve,f,g,dir,aveLoc)
       public :: face2Node            ! call face2Node(nodeAverage,face,g,dir)           *
       public :: face2CellCenter      ! call face2CellCenter(cellCenter,face,g,faceDir)  *
       public :: face2Edge            ! call face2Edge(edge,g,face,edgeDir)

       public :: cellCenter2Face      ! call cellCenter2Face(face,cellCenter,g,faceDir)  *
       public :: cellCenter2Edge      ! call cellCenter2Edge(edge,cellCenter,g,edgeDir)  *
       public :: cellCenter2Node      ! call cellCenter2Node(nodeAverage,cellCenter,g)   *

       public :: edge2Face            ! call edge2Face(face,edge,g,edgeDir,faceDir)
       public :: edge2Node            ! call edge2Node(node,edge,g,edgeDir)              *
       public :: edge2CellCenter      ! call edge2CellCenter(cellCenter,edge,g,edgeDir)
       
       public :: node2Face            ! call node2Face(face,node,g,faceDir)              *
       public :: node2Edge            ! call node2Edge(edge,node,g,edgeDir)              *

       ! * = has vector interface

       interface interp;              module procedure interpO2_RF;          end interface
       interface extrap;              module procedure extrapO2_RF;          end interface
       interface interp;              module procedure interpO2_SF;          end interface
       interface extrap;              module procedure extrapO2_SF;          end interface

       ! RF interps

       interface face2CellCenter;     module procedure face2CellCenter_RF;    end interface
       interface face2Edge;           module procedure face2Edge_RF;          end interface
       interface face2Face;           module procedure face2Face_RF;          end interface
       interface face2Node;           module procedure face2Node_RF;          end interface

       interface cellCenter2Face;     module procedure cellCenter2Face_RF;    end interface
       interface cellCenter2Node;     module procedure cellCenter2Node_RF;    end interface
       interface cellCenter2Edge;     module procedure cellCenter2Edge_RF;    end interface

       interface node2Face;           module procedure node2Face_RF;          end interface
       interface node2edge;           module procedure node2Edge_RF;          end interface

       interface edge2CellCenter;     module procedure edge2CellCenter_RF;    end interface
       interface edge2Face;           module procedure edge2Face_RF;          end interface
       interface edge2Node;           module procedure edge2Node_RF;          end interface

       ! SF interps

       interface face2CellCenter;     module procedure face2CellCenter_SF;    end interface
       interface face2Edge;           module procedure face2Edge_SF;          end interface
       interface face2Face;           module procedure face2Face_SF;          end interface
       interface face2Node;           module procedure face2Node_SF;          end interface

       interface cellCenter2Face;     module procedure cellCenter2Face_SF;    end interface
       interface cellCenter2Node;     module procedure cellCenter2Node_SF;    end interface
       interface cellCenter2Edge;     module procedure cellCenter2Edge_SF;    end interface

       interface node2Edge;           module procedure node2Edge_SF;          end interface
       interface node2Face;           module procedure node2Face_SF;          end interface

       interface edge2Face;           module procedure edge2Face_SF;          end interface
       interface edge2CellCenter;     module procedure edge2CellCenter_SF;    end interface
       interface edge2Node;           module procedure edge2Node_SF;          end interface

       ! VF interps

       interface face2Face;           module procedure face2Face_VF;          end interface
       interface face2CellCenter;     module procedure face2CellCenter_VF;    end interface
       interface face2Node;           module procedure face2Node_VF;          end interface

       interface cellCenter2Face;     module procedure cellCenter2Face_VF;    end interface
       interface cellCenter2Face;     module procedure cellCenter2Face2_VF;   end interface
       interface cellCenter2Node;     module procedure cellCenter2Node_VF;    end interface
       interface cellCenter2Edge;     module procedure cellCenter2Edge_VF;    end interface
       interface cellCenter2Edge;     module procedure cellCenter2Edge2_VF;   end interface

       interface edge2Node;           module procedure edge2Node_VF;          end interface
       interface edge2CellCenter;     module procedure edge2CellCenter_VF;    end interface

       interface node2Face;           module procedure node2Face_VF;          end interface
       interface node2Face;           module procedure node2Face2_VF;         end interface

       interface node2Edge;           module procedure node2Edge_VF;          end interface
       interface node2Edge;           module procedure node2Edge2_VF;         end interface

       contains

       ! ****************************************************************************************
       ! ****************************************************************************************
       ! ********************************* BASE INTERPOLATION ***********************************
       ! ****************************************************************************************
       ! ****************************************************************************************

       subroutine interpO2_RF(f,g,gd,dir)
         ! interpO2 interpolates g from the primary grid to the
         ! dual grid using a 2nd order accurate stencil for non-uniform 
         ! grids. f lives on the dual grid. It is expected that
         ! f lives between g.
         ! 
         ! Reminder: f = interp(g)
         ! 
         ! * = assigned in this routine. This way, the entire
         ! array of f and g may be passed, without having to 
         ! index.
         ! 
         ! Therefore, shape(g) = shape(f) + 1 along dir
         ! Otherwise, shape(g) = shape(f)
         ! 
         ! Add internal checking of shape of f and g and grid
         ! 
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: f
         real(cp),dimension(:,:,:),intent(in) :: g
         type(grid),intent(in) :: gd
         integer,intent(in) :: dir
         integer :: i,j,k,t,x,y,z
         real(cp) :: alpha
         integer,dimension(3) :: sg,sf
         sf = shape(f); sg = shape(g)

         select case (dir)
         case (1); x=1;y=0;z=0
         case (2); x=0;y=1;z=0
         case (3); x=0;y=0;z=1
         case default
           stop 'Error: dir must = 1,2,3 in interpO2.'
         end select

#ifdef _DEBUG_INTERP_
         select case (dir)
         case (1)
         if (sf(2).ne.sg(2)) stop 'Erorr: shape mismatch in interpOps.f90'
         if (sf(3).ne.sg(3)) stop 'Erorr: shape mismatch in interpOps.f90'
         case (2)
         if (sf(1).ne.sg(1)) stop 'Erorr: shape mismatch in interpOps.f90'
         if (sf(3).ne.sg(3)) stop 'Erorr: shape mismatch in interpOps.f90'
         case (3)
         if (sf(1).ne.sg(1)) stop 'Erorr: shape mismatch in interpOps.f90'
         if (sf(2).ne.sg(2)) stop 'Erorr: shape mismatch in interpOps.f90'
         case default
           stop 'Error: dir must = 1,2,3 in interpO2.'
         end select
#endif

         if ((sf(dir).eq.gd%c(dir)%sc).and.(sg(dir).eq.gd%c(dir)%sn)) then
           ! f(cc grid), g(node/face grid)
           !         g  f  g  f  g  f  g  f  g
           !         |--o--|--o--|--o--|--o--|   --> dir
           !            *     *     *     *
           
           !$OMP PARALLEL DO
           do k=1,sg(3)-z
             do j=1,sg(2)-y
               do i=1,sg(1)-x
                 f(i,j,k) = (g(i,j,k)+g(i+x,j+y,k+z))/2.0_cp
               enddo
             enddo
           enddo
           !$OMP END PARALLEL DO
         elseif ((sf(dir).eq.gd%c(dir)%sn).and.(sg(dir).eq.gd%c(dir)%sc)) then
           ! f(node/face grid), g(cc grid)
           !         f  g  f  g  f  g  f  g  f
           !         |--o--|--o--|--o--|--o--|      --> dir
           !               *     *     *

           !$OMP PARALLEL PRIVATE(alpha,t)
           !$OMP DO
           do k=1,sg(3)-z
             do j=1,sg(2)-y
               do i=1,sg(1)-x
                 t = i*x + j*y + k*z
                 alpha = (gd%c(dir)%hn(t+1) - gd%c(dir)%hc(t))/(gd%c(dir)%hc(t+1) - gd%c(dir)%hc(t))
                 f(i+x,j+y,k+z) = g(i+x,j+y,k+z)*alpha + &
                                  g(i,j,k)*(1.0_cp-alpha)
               enddo
             enddo
           enddo
           !$OMP END DO
           !$OMP END PARALLEL
           call extrapO2(f,g,dir)
         else
           stop 'gridType must be 1 or 2 in interpO2. Terminating.'
         endif
       end subroutine

       subroutine extrapO2_RF(f,g,dir)
         ! extrapO2 extrapolates g from the primary grid to the
         ! dual grid using a 2nd order accurate stencil for 
         ! non-uniform grids. f lives on the dual grid. 
         ! It is expected that f lives between g.
         ! 
         ! Reminder: f = extrap(g)
         ! 
         ! For interpO2, this corresponds to the case:
         ! f(cc grid), g(node/face grid)
         ! 
         !         f  g  f  g  f  g  f  g  f
         !         |--o--|--o--|--o--|--o--|    --> dir
         !         *                       *
         ! 
         ! * = assigned in this routine. This way, the entire
         ! array of f and g may be passed, without having to 
         ! index.
         ! 
         ! Therefore, size(f) = size(g) + 1 along dir
         ! Otherwise, size(f) = size(g)
         ! 
         implicit none
         real(cp),dimension(:,:,:),intent(in) :: g
         real(cp),dimension(:,:,:),intent(inout) :: f
         integer,intent(in) :: dir
         integer,dimension(3) :: sg,sf
         sg = shape(g); sf = shape(f)
         ! Both cases are simple since the size of the 
         ! first 2 cells are equal, we have
         ! 
         ! f_ghost + f_boundary
         ! --------------------  = g    -->  f_ghost = 2g - f_boundary
         !          2
         ! 
         ! BACKWARD EXTRAPOLATION (* = assigned)
         !         f  g  f  g  f  g  f  g  f
         !         |--o--|--o--|--o--|--o--|    --> dir
         !         *
         ! 
         select case (dir)
         case (1); f(1,:,:) = 2.0_cp*g(1,:,:) - f(2,:,:)
         case (2); f(:,1,:) = 2.0_cp*g(:,1,:) - f(:,2,:)
         case (3); f(:,:,1) = 2.0_cp*g(:,:,1) - f(:,:,2)
         end select
         ! FORWARD EXTRAPOLATION (* = assigned)
         !         f  g  f  g  f  g  f  g  f
         !         |--o--|--o--|--o--|--o--|    --> dir
         !                                 *
         select case (dir)
         case (1); f(sf(1),:,:) = 2.0_cp*g(sg(1),:,:) - f(sf(1)-1,:,:)
         case (2); f(:,sf(2),:) = 2.0_cp*g(:,sg(2),:) - f(:,sf(2)-1,:)
         case (3); f(:,:,sf(3)) = 2.0_cp*g(:,:,sg(3)) - f(:,:,sf(3)-1)
         end select
       end subroutine

       subroutine interpO2_SF(f,g,gd,dir)
         implicit none
         type(SF),intent(inout) :: f
         type(SF),intent(in) :: g
         type(grid),intent(in) :: gd
         integer,intent(in) :: dir
         integer :: i
         do i=1,f%s
           call interp(f%RF(i)%f,g%RF(i)%f,gd,dir)
         enddo
       end subroutine

       subroutine extrapO2_SF(f,g,dir)
         implicit none
         type(SF),intent(in) :: g
         type(SF),intent(inout) :: f
         integer,intent(in) :: dir
         integer :: i
         do i=1,f%s
           call extrap(f%RF(i)%f,g%RF(i)%f,dir)
         enddo
       end subroutine


       ! ****************************************************************************************
       ! ****************************************************************************************
       ! ***************************** REAL FIELD INTERPOLATIONS ********************************
       ! ****************************************************************************************
       ! ****************************************************************************************

       ! ****************************************************************************************
       ! ********************************* FACE INTERPOLATIONS **********************************
       ! ****************************************************************************************

       subroutine face2CellCenter_RF(cellCenter,face,g,faceDir)
         ! 1 interpolation routine (no allocation required)
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: cellCenter
         real(cp),dimension(:,:,:),intent(in)    :: face
         type(grid),intent(in) :: g
         integer,intent(in) :: faceDir
         call interp(cellCenter,face,g,faceDir)
       end subroutine

       subroutine face2Edge_RF(edge,face,g,faceDir,edgeDir)
         ! Case dependent multiple-interpolation routine (requires 1 or 3 interpolations)
         ! 
         ! This routine moves 
         !       face data along direction faceDir
         !    to edge data along direction edgeDir
         ! 
         ! edgeDir is defined as the direction along which the dimension is of size N+2
         ! faceDir is defined as the direction along which the dimension is of size N+1
         ! 
         ! Where N is the number of cells.
         ! 
         ! This means that there are 2 possible cases:
         !    edgeDir == faceDir       (requires 3 interpolations, 1 to cell center, 2 to edge)
         !    edgeDir ≠ faceDir        (requires 1 interpolation)
         ! 
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: edge
         real(cp),dimension(:,:,:),intent(in)    :: face
         type(grid),intent(in) :: g
         integer,intent(in) :: edgeDir,faceDir

         real(cp),dimension(:,:,:),allocatable :: tempCC
         integer :: orthDir
         if (edgeDir.ne.faceDir) then ! requires 1 interpolation (no allocations)
           orthDir = orthogonalDirection(edgeDir,faceDir)
           call interp(edge,face,g,orthDir)
         else ! Requires 3 interpolations ()
           allocate(tempCC(g%c(1)%sc,g%c(2)%sc,g%c(3)%sc))
           call face2CellCenter(tempCC,face,g,faceDir)
           call cellCenter2Edge(edge,tempCC,g,edgeDir)
           deallocate(tempCC)
         endif
       end subroutine

       subroutine face2Face_RF(faceAve,face,g,faceDir,aveLoc)
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: faceAve
         real(cp),dimension(:,:,:),intent(in) :: face
         type(grid),intent(in) :: g
         integer,intent(in) :: faceDir,aveLoc
         real(cp),dimension(:,:,:),allocatable :: cellCenter
         allocate(cellCenter(g%c(1)%sc,g%c(2)%sc,g%c(3)%sc))
         call face2CellCenter(cellCenter,face,g,faceDir)
         call cellCenter2Face(faceAve,cellCenter,g,aveLoc)
         deallocate(cellCenter)
       end subroutine

       subroutine face2Node_RF(node,face,g,faceDir)
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: node
         real(cp),dimension(:,:,:),intent(in) :: face
         type(grid),intent(in) :: g
         integer,intent(in) :: faceDir
         real(cp),dimension(:,:,:),allocatable :: edge
         integer :: edgeDir
         select case (faceDir)
         case (1); edgeDir = 2
         case (2); edgeDir = 1
         case (3); edgeDir = 1
         case default
           stop 'Error: faceDir must = 1,2,3 in face2Node.'
         end select
         select case (edgeDir)
         case (1); allocate(edge(g%c(1)%sc,g%c(2)%sn,g%c(3)%sn))
         case (2); allocate(edge(g%c(1)%sn,g%c(2)%sc,g%c(3)%sn))
         case (3); allocate(edge(g%c(1)%sn,g%c(2)%sn,g%c(3)%sc))
         case default
           stop 'Error: faceDir must = 1,2,3 in face2Node.'
         end select

         call face2Edge(edge,face,g,faceDir,edgeDir)
         call edge2Node(node,edge,g,edgeDir)
         deallocate(edge)
       end subroutine

       ! ****************************************************************************************
       ! *********************************** CC INTERPOLATIONS **********************************
       ! ****************************************************************************************

       subroutine cellCenter2Face_RF(face,cellCenter,g,faceDir)
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: face
         real(cp),dimension(:,:,:),intent(in) :: cellCenter
         type(grid),intent(in) :: g
         integer,intent(in) :: faceDir
         call interp(face,cellCenter,g,faceDir)
       end subroutine

       subroutine cellCenter2Node_RF(node,cellCenter,g)
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: node
         real(cp),dimension(:,:,:),intent(in) :: cellCenter
         type(grid),intent(in) :: g
         real(cp),dimension(:,:,:),allocatable :: face,edge
         allocate(face(g%c(1)%sn,g%c(2)%sc,g%c(3)%sc))
         call cellCenter2Face(face,cellCenter,g,1)
         allocate(edge(g%c(1)%sn,g%c(2)%sn,g%c(3)%sc))
         call face2Edge(edge,face,g,1,3)
         deallocate(face)
         call edge2Node(node,edge,g,3)
         deallocate(edge)
       end subroutine

       subroutine cellCenter2Edge_RF(edge,cellCenter,g,edgeDir)
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: edge
         real(cp),dimension(:,:,:),intent(in) :: cellCenter
         type(grid),intent(in) :: g
         integer,intent(in) :: edgeDir
         real(cp),dimension(:,:,:),allocatable :: faceTemp
         integer,dimension(3) :: s
         s = shape(cellCenter)

         select case (edgeDir)
         case(1); allocate(faceTemp(g%c(1)%sc,g%c(2)%sn,g%c(3)%sc))
         call cellCenter2Face(faceTemp,cellCenter,g,2)
         call face2Edge(edge,faceTemp,g,2,1)
         case(2); allocate(faceTemp(g%c(1)%sn,g%c(2)%sc,g%c(3)%sc))
         call cellCenter2Face(faceTemp,cellCenter,g,1)
         call face2Edge(edge,faceTemp,g,1,2)
         case(3); allocate(faceTemp(g%c(1)%sn,g%c(2)%sc,g%c(3)%sc))
         call cellCenter2Face(faceTemp,cellCenter,g,1)
         call face2Edge(edge,faceTemp,g,1,3)
         case default
           stop 'Error: edgeDir must = 1,2,3 in cellCenter2Edge.'
         end select
         deallocate(faceTemp)
       end subroutine

       ! ****************************************************************************************
       ! ********************************* NODE INTERPOLATIONS **********************************
       ! ****************************************************************************************

       subroutine node2Face_RF(face,node,g,faceDir)
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: face
         real(cp),dimension(:,:,:),intent(in) :: node
         real(cp),dimension(:,:,:),allocatable :: tempe
         type(grid),intent(in) :: g
         integer,intent(in) :: faceDir
         integer,dimension(3) :: s
         s = shape(node)
         select case (faceDir)
         case (1)
           allocate(tempe(g%c(1)%sn,g%c(2)%sc,g%c(3)%sn))
           call node2Edge(tempe,node,g,2)
           call edge2Face(face,tempe,g,2,faceDir)
           deallocate(tempe)
         case (2)
           allocate(tempe(g%c(1)%sc,g%c(2)%sn,g%c(3)%sn))
           call node2Edge(tempe,node,g,1)
           call edge2Face(face,tempe,g,1,faceDir)
           deallocate(tempe)
         case (3)
           allocate(tempe(g%c(1)%sc,g%c(2)%sn,g%c(3)%sn))
           call node2Edge(tempe,node,g,1)
           call edge2Face(face,tempe,g,1,faceDir)
           deallocate(tempe)
         case default
           stop 'Error: faceDir must = 1,2,3 in node2Face.'
         end select
       end subroutine

       subroutine node2Edge_RF(edge,node,g,edgeDir)
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: edge
         real(cp),dimension(:,:,:),intent(in) :: node
         type(grid),intent(in) :: g
         integer,intent(in) :: edgeDir
         call interp(edge,node,g,edgeDir)
       end subroutine

       ! ****************************************************************************************
       ! ********************************* EDGE INTERPOLATIONS **********************************
       ! ****************************************************************************************

       subroutine edge2Face_RF(face,edge,g,edgeDir,faceDir)
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: face
         real(cp),dimension(:,:,:),intent(in) :: edge
         type(grid),intent(in) :: g
         integer,intent(in) :: faceDir,edgeDir
         integer :: orthDir
         orthDir = orthogonalDirection(edgeDir,faceDir)
         call interp(face,edge,g,orthDir)
       end subroutine

       subroutine edge2CellCenter_RF(cellCenter,edge,g,edgeDir)
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: cellCenter
         real(cp),dimension(:,:,:),intent(in) :: edge
         type(grid),intent(in) :: g
         integer,intent(in) :: edgeDir
         real(cp),dimension(:,:,:),allocatable :: tempF
         integer :: faceDir
         select case (edgeDir)
         case (1); faceDir = 2; allocate(tempF(g%c(1)%sc,g%c(2)%sn,g%c(3)%sc))
         case (2); faceDir = 3; allocate(tempF(g%c(1)%sc,g%c(2)%sc,g%c(3)%sn))
         case (3); faceDir = 1; allocate(tempF(g%c(1)%sn,g%c(2)%sc,g%c(3)%sc))
         case default
         stop 'Error: edgeDir must = 1,2,3 in edge2CellCenter_RF in interpOps.f90'
         end select
         call edge2Face(tempF,edge,g,edgeDir,faceDir)
         call face2CellCenter(cellCenter,tempF,g,faceDir)
         deallocate(tempF)
       end subroutine

       subroutine edge2Node_RF(node,edge,g,edgeDir)
         implicit none
         real(cp),dimension(:,:,:),intent(inout) :: node
         real(cp),dimension(:,:,:),intent(in) :: edge
         type(grid),intent(in) :: g
         integer,intent(in) :: edgeDir
         call interp(node,edge,g,edgeDir)
       end subroutine

       ! ****************************************************************************************
       ! ****************************************************************************************
       ! ****************************** SCALAR-FIELD INTERPOLATIONS *****************************
       ! ****************************************************************************************
       ! ****************************************************************************************

       ! ****************************************************************************************
       ! ********************************* FACE INTERPOLATIONS **********************************
       ! ****************************************************************************************

       subroutine face2CellCenter_SF(cellCenter,face,g,faceDir)
         ! 1 interpolation routine (no allocation required)
         implicit none
         type(SF),intent(inout) :: cellCenter
         type(SF),intent(in)    :: face
         type(grid),intent(in) :: g
         integer,intent(in) :: faceDir
         call interp(cellCenter,face,g,faceDir)
       end subroutine

       subroutine face2Edge_SF(edge,face,g,faceDir,edgeDir)
         implicit none
         type(SF),intent(inout) :: edge
         type(SF),intent(in)    :: face
         type(grid),intent(in) :: g
         integer,intent(in) :: edgeDir,faceDir
         integer :: i
         do i=1,edge%s
           call face2Edge(edge%RF(i)%f,face%RF(i)%f,g,faceDir,edgeDir)
         enddo
       end subroutine

       subroutine face2Face_SF(faceAve,face,g,faceDir,aveLoc)
         implicit none
         type(SF),intent(inout) :: faceAve
         type(SF),intent(in) :: face
         type(grid),intent(in) :: g
         integer,intent(in) :: faceDir,aveLoc
         integer :: i
         do i=1,faceAve%s
           call face2Face(faceAve%RF(i)%f,face%RF(i)%f,g,faceDir,aveLoc)
         enddo
       end subroutine

       subroutine face2Node_SF(node,face,g,faceDir)
         implicit none
         type(SF),intent(inout) :: node
         type(SF),intent(in) :: face
         type(grid),intent(in) :: g
         integer,intent(in) :: faceDir
         integer :: i
         do i=1,node%s
           call face2Node(node%RF(i)%f,face%RF(i)%f,g,faceDir)
         enddo
       end subroutine

       ! ****************************************************************************************
       ! *********************************** CC INTERPOLATIONS **********************************
       ! ****************************************************************************************

       subroutine cellCenter2Face_SF(face,cellCenter,g,faceDir)
         implicit none
         type(SF),intent(inout) :: face
         type(SF),intent(in) :: cellCenter
         type(grid),intent(in) :: g
         integer,intent(in) :: faceDir
         call interp(face,cellCenter,g,faceDir)
       end subroutine

       subroutine cellCenter2Node_SF(node,cellCenter,g)
         implicit none
         type(SF),intent(inout) :: node
         type(SF),intent(in) :: cellCenter
         type(grid),intent(in) :: g
         integer :: i
         do i=1,node%s
           call cellCenter2Node(node%RF(i)%f,cellCenter%RF(i)%f,g)
         enddo
       end subroutine

       subroutine cellCenter2Edge_SF(edge,cellCenter,g,edgeDir)
         implicit none
         type(SF),intent(inout) :: edge
         type(SF),intent(in) :: cellCenter
         type(grid),intent(in) :: g
         integer,intent(in) :: edgeDir
         integer :: i
         do i=1,edge%s
           call cellCenter2Edge(edge%RF(i)%f,cellCenter%RF(i)%f,g,edgeDir)
         enddo
       end subroutine

       ! ****************************************************************************************
       ! ********************************* NODE INTERPOLATIONS **********************************
       ! ****************************************************************************************

       subroutine node2Edge_SF(edge,node,g,edgeDir)
         implicit none
         type(SF),intent(inout) :: edge
         type(SF),intent(in) :: node
         type(grid),intent(in) :: g
         integer,intent(in) :: edgeDir
         call interp(edge,node,g,edgeDir)
       end subroutine

       subroutine node2Face_SF(face,node,g,faceDir)
         implicit none
         type(SF),intent(inout) :: face
         type(SF),intent(in) :: node
         type(grid),intent(in) :: g
         integer,intent(in) :: faceDir
         integer :: i
         do i=1,face%s
           call node2Face(face%RF(i)%f,node%RF(i)%f,g,faceDir)
         enddo
       end subroutine

       ! ****************************************************************************************
       ! ********************************* EDGE INTERPOLATIONS **********************************
       ! ****************************************************************************************

       subroutine edge2Face_SF(face,edge,g,edgeDir,faceDir)
         implicit none
         type(SF),intent(inout) :: face
         type(SF),intent(in) :: edge
         type(grid),intent(in) :: g
         integer,intent(in) :: faceDir,edgeDir
         integer :: orthDir
         orthDir = orthogonalDirection(edgeDir,faceDir)
         call interp(face,edge,g,orthDir)
       end subroutine

       subroutine edge2CellCenter_SF(cellCenter,edge,g,edgeDir)
         implicit none
         type(SF),intent(inout) :: cellCenter
         type(SF),intent(in) :: edge
         type(grid),intent(in) :: g
         integer,intent(in) :: edgeDir
         integer :: i
         do i=1,cellCenter%s
           call edge2CellCenter(cellCenter%RF(i)%f,edge%RF(i)%f,g,edgeDir)
         enddo
       end subroutine

       subroutine edge2Node_SF(node,edge,g,edgeDir)
         implicit none
         type(SF),intent(inout) :: node
         type(SF),intent(in) :: edge
         type(grid),intent(in) :: g
         integer,intent(in) :: edgeDir
         call interp(node,edge,g,edgeDir)
       end subroutine

       ! ****************************************************************************************
       ! ****************************************************************************************
       ! ****************************** VECTOR-FIELD INTERPOLATIONS *****************************
       ! ****************************************************************************************
       ! ****************************************************************************************


       ! ****************************************************************************************
       ! ********************************* FACE INTERPOLATIONS **********************************
       ! ****************************************************************************************

       subroutine face2Face_VF(faceX,faceY,faceZ,face,g)
         ! [U_ave,V_ave,W_ave] = interp(U)
         implicit none
         type(VF),intent(inout) :: faceX,faceY,faceZ
         type(VF),intent(in)    :: face
         type(grid),intent(in) :: g

         call assignX(faceX,face)
         call assignY(faceY,face)
         call assignZ(faceZ,face)

         call face2Face(faceX%y,face%x,g,1,2)
         call face2Face(faceX%z,face%x,g,1,3)

         call face2Face(faceY%x,face%y,g,2,1)
         call face2Face(faceY%z,face%y,g,2,3)

         call face2Face(faceZ%x,face%z,g,3,1)
         call face2Face(faceZ%y,face%z,g,3,2)
       end subroutine

       subroutine face2CellCenter_VF(cellCenter,face,g)
         implicit none
         type(VF),intent(inout) :: cellCenter
         type(VF),intent(in)    :: face
         type(grid),intent(in) :: g
         call face2CellCenter(cellCenter%x,face%x,g,1)
         call face2CellCenter(cellCenter%y,face%y,g,2)
         call face2CellCenter(cellCenter%z,face%z,g,3)
       end subroutine

       subroutine face2Node_VF(node,face,g)
         implicit none
         type(VF),intent(inout) :: node
         type(VF),intent(in) :: face
         type(grid),intent(in) :: g
         call face2Node(node%x,face%x,g,1)
         call face2Node(node%y,face%y,g,2)
         call face2Node(node%z,face%z,g,3)
       end subroutine

       ! ****************************************************************************************
       ! *********************************** CC INTERPOLATIONS **********************************
       ! ****************************************************************************************

       subroutine cellCenter2Face_VF(face,cellCenter,g)
         implicit none
         type(VF),intent(inout) :: face
         type(VF),intent(in) :: cellCenter
         type(grid),intent(in) :: g
         call cellCenter2Face(face%x,cellCenter%x,g,1)
         call cellCenter2Face(face%y,cellCenter%y,g,2)
         call cellCenter2Face(face%z,cellCenter%z,g,3)
       end subroutine

       subroutine cellCenter2Face2_VF(face,cellCenter,g)
         implicit none
         type(VF),intent(inout) :: face
         type(SF),intent(in) :: cellCenter
         type(grid),intent(in) :: g
         call cellCenter2Face(face%x,cellCenter,g,1)
         call cellCenter2Face(face%y,cellCenter,g,2)
         call cellCenter2Face(face%z,cellCenter,g,3)
       end subroutine

       subroutine cellCenter2Node_VF(node,cellCenter,g)
         implicit none
         type(VF),intent(inout) :: node
         type(VF),intent(in) :: cellCenter
         type(grid),intent(in) :: g
         call cellCenter2Node(node%x,cellCenter%x,g)
         call cellCenter2Node(node%y,cellCenter%y,g)
         call cellCenter2Node(node%z,cellCenter%z,g)
       end subroutine

       subroutine cellCenter2Edge_VF(edge,cellCenter,g)
         implicit none
         type(VF),intent(inout) :: edge
         type(VF),intent(in) :: cellCenter
         type(grid),intent(in) :: g
         call cellCenter2Edge(edge%x,cellCenter%x,g,1)
         call cellCenter2Edge(edge%y,cellCenter%y,g,2)
         call cellCenter2Edge(edge%z,cellCenter%z,g,3)
       end subroutine

       subroutine cellCenter2Edge2_VF(edge,cellCenter,g)
         implicit none
         type(VF),intent(inout) :: edge
         type(SF),intent(in) :: cellCenter
         type(grid),intent(in) :: g
         call cellCenter2Edge(edge%x,cellCenter,g,1)
         call cellCenter2Edge(edge%y,cellCenter,g,2)
         call cellCenter2Edge(edge%z,cellCenter,g,3)
       end subroutine

       ! ****************************************************************************************
       ! ********************************* NODE INTERPOLATIONS **********************************
       ! ****************************************************************************************

       subroutine node2Edge_VF(edge,node,g)
         implicit none
         type(VF),intent(inout) :: edge
         type(VF),intent(in) :: node
         type(grid),intent(in) :: g
         call node2Edge(edge%x,node%x,g,1)
         call node2Edge(edge%y,node%y,g,2)
         call node2Edge(edge%z,node%z,g,3)
       end subroutine

       subroutine node2Edge2_VF(edge,node,g)
         implicit none
         type(VF),intent(inout) :: edge
         type(SF),intent(in) :: node
         type(grid),intent(in) :: g
         call node2Edge(edge%x,node,g,1)
         call node2Edge(edge%y,node,g,2)
         call node2Edge(edge%z,node,g,3)
       end subroutine

       subroutine node2Face_VF(face,node,g)
         implicit none
         type(VF),intent(inout) :: face
         type(VF),intent(in) :: node
         type(grid),intent(in) :: g
         call node2Face(face%x,node%x,g,1)
         call node2Face(face%y,node%y,g,2)
         call node2Face(face%z,node%z,g,3)
       end subroutine

       subroutine node2Face2_VF(face,node,g)
         implicit none
         type(VF),intent(inout) :: face
         type(SF),intent(in) :: node
         type(grid),intent(in) :: g
         call node2Face(face%x,node,g,1)
         call node2Face(face%y,node,g,2)
         call node2Face(face%z,node,g,3)
       end subroutine

       ! ****************************************************************************************
       ! ********************************* EDGE INTERPOLATIONS **********************************
       ! ****************************************************************************************

       subroutine edge2Node_VF(node,edge,g)
         implicit none
         type(VF),intent(inout) :: node
         type(VF),intent(in) :: edge
         type(grid),intent(in) :: g
         call edge2Node(node%x,edge%x,g,1)
         call edge2Node(node%y,edge%y,g,2)
         call edge2Node(node%z,edge%z,g,3)
       end subroutine

       subroutine edge2CellCenter_VF(cellCenter,edge,g)
         implicit none
         type(VF),intent(inout) :: cellCenter
         type(VF),intent(in) :: edge
         type(grid),intent(in) :: g
         call edge2CellCenter(cellCenter%x,edge%x,g,1)
         call edge2CellCenter(cellCenter%y,edge%y,g,2)
         call edge2CellCenter(cellCenter%z,edge%z,g,3)
       end subroutine

       ! ****************************************************************************************
       ! ****************************************************************************************
       ! *********************************** AUXILIARY ROUTINES *********************************
       ! ****************************************************************************************
       ! ****************************************************************************************

       function orthogonalDirection(dir1,dir2) result(orthDir)
         implicit none
         integer,intent(in) :: dir1,dir2
         integer :: orthDir
         select case (dir1)
           case (1);
             select case (dir2)
             case (2); orthDir = 3
             case (3); orthDir = 2
             case default
               stop 'Error: bad input to orthogonalDirection'
             end select
           case (2);
             select case (dir2)
             case (1); orthDir = 3
             case (3); orthDir = 1
             case default
               stop 'Error: bad input to orthogonalDirection'
             end select
           case (3);
             select case (dir2)
             case (1); orthDir = 2
             case (2); orthDir = 1
             case default
               stop 'Error: bad input to orthogonalDirection'
             end select
           case default
             stop 'Error: bad input to orthogonalDirection'
         end select
       end function

       end module