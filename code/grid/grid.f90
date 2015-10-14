       module grid_mod
      ! Pre-processor directives: (_DEBUG_COORDINATES_)
       use IO_tools_mod
       use coordinates_mod
       use stitch_mod
       implicit none

#ifdef _SINGLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(8)
#endif
#ifdef _DOUBLE_PRECISION_
       integer,parameter :: cp = selected_real_kind(14)
#endif
#ifdef _QUAD_PRECISION_
       integer,parameter :: cp = selected_real_kind(32)
#endif

       private
       public :: grid
       public :: init,delete
       public :: print,export ! import
       public :: print_all,export_all
       public :: restrict,restrict_x,restrict_xy
       public :: initProps

#ifdef _DEBUG_COORDINATES_
      public :: checkGrid
#endif

       type grid
         type(coordinates),dimension(3) :: c ! hn,hc,dhn,dhc / dhMin,maxRange
         type(stitch),dimension(3) :: st
         ! Properties
         real(cp) :: dhMin,dhMax,maxRange,volume
         integer :: N_cells
         logical :: defined
       end type

       interface init;           module procedure initGridCopy;        end interface
       interface init;           module procedure initGrid1;           end interface
       interface init;           module procedure initGrid2;           end interface
       interface initProps;      module procedure initProps_grid;      end interface
       interface delete;         module procedure deleteGrid;          end interface

       interface restrict;       module procedure restrictGrid1;       end interface
       interface restrict;       module procedure restrictGrid3;       end interface
       interface restrict_x;     module procedure restrictGrid_x;      end interface
       interface restrict_xy;    module procedure restrictGrid_xy;     end interface

       interface print;          module procedure print_Grid;          end interface
       interface print_all;      module procedure print_Grid_all;      end interface
       interface export;         module procedure export_Grid;         end interface
       interface export_all;     module procedure export_Grid_all;     end interface

       contains

       subroutine deleteGrid(g)
         implicit none
         type(grid),intent(inout) :: g
         integer :: i
         do i = 1,3; call delete(g%c(i)) ;enddo
         do i = 1,3; call delete(g%st(i)) ;enddo
         call initProps(g)
         ! write(*,*) 'Grid deleted'
       end subroutine

       subroutine initGridCopy(g,f)
         implicit none
         type(grid),intent(inout) :: g
         type(grid),intent(in) :: f
         integer :: i
         do i = 1,3; call init(g%c(i),f%c(i)) ;enddo
         do i = 1,3; call init(g%st(i),f%st(i)) ;enddo
         call initProps(g)
         if (.not.g%defined) stop 'Error: tried copying grid that was not fully defined'
       end subroutine

       subroutine initGrid1(g,h,dir)
         implicit none
         type(grid),intent(inout) :: g
         real(cp),dimension(:),intent(in) :: h
         integer,intent(in) :: dir
         integer :: i
         call init(g%c(dir),h,size(h))
         if (all((/(allocated(g%c(i)%hn),i=1,3)/))) then
           call initProps(g)
#ifdef _DEBUG_COORDINATES_
           call checkGrid(g)
#endif
         endif
       end subroutine

       subroutine initGrid2(g,h1,h2,h3)
         implicit none
         type(grid),intent(inout) :: g
         real(cp),dimension(:),intent(in) :: h1,h2,h3
         call init(g%c(1),h1,size(h1))
         call init(g%c(2),h2,size(h2))
         call init(g%c(3),h3,size(h3))
         call initProps(g)
       end subroutine

       subroutine initProps_grid(g)
         implicit none
         type(grid),intent(inout) :: g
         integer :: i
         g%dhMin = minval((/g%c(1)%dhMin,g%c(2)%dhMin,g%c(3)%dhMin/))
         g%dhMax = maxval((/g%c(1)%dhMax,g%c(2)%dhMax,g%c(3)%dhMax/))
         g%maxRange = maxval((/g%c(1)%maxRange,g%c(2)%maxRange,g%c(3)%maxRange/))
         g%volume = g%c(1)%maxRange*g%c(2)%maxRange*g%c(3)%maxRange
         g%N_cells = g%c(1)%N + g%c(2)%N + g%c(3)%N
         g%defined = all((/(g%c(i)%defined,i=1,3)/))
       end subroutine
        
       ! ------------------- restrict (for multigrid) --------------

       subroutine restrictGrid1(r,g,dir)
         type(grid),intent(inout) :: r
         type(grid),intent(in) :: g
         integer,intent(in) :: dir
         call restrict(r%c(dir),g%c(dir))
       end subroutine

       subroutine restrictGrid3(r,g)
         type(grid),intent(inout) :: r
         type(grid),intent(in) :: g
         integer :: i
         do i = 1,3; call restrict(r%c(i),g%c(i)) ;enddo
       end subroutine

       subroutine restrictGrid_x(r,g)
         type(grid),intent(inout) :: r
         type(grid),intent(in) :: g
         call restrict(r%c(1),g%c(1))
       end subroutine

       subroutine restrictGrid_xy(r,g)
         type(grid),intent(inout) :: r
         type(grid),intent(in) :: g
         call restrict(r%c(1),g%c(1))
         call restrict(r%c(2),g%c(2))
       end subroutine

       ! ---------------------------------------------- check grid

#ifdef _DEBUG_COORDINATES_
       subroutine checkGrid(g)
         implicit none
         type(grid),intent(in) :: g
         integer :: i
         do i=1,3; call checkCoordinates(g%c(i)); enddo
       end subroutine
#endif

       subroutine export_grid_all(g,un)
         implicit none
         type(grid), intent(in) :: g
         integer,intent(in) :: un
         integer :: i
         call export(g,un)
         do i = 1,3; call export(g%c(i),un) ;enddo
       end subroutine

       subroutine export_grid(g,un)
         implicit none
         type(grid), intent(in) :: g
         integer,intent(in) :: un
         write(un,*) ' ---------------- grid'
         write(un,*) 'N_cells = ',(/g%c(1)%N,g%c(2)%N,g%c(3)%N/)
         write(un,*) 'volume = ',g%volume
         write(un,*) 'min/max(h)_x = ',(/g%c(1)%hmin,g%c(1)%hmax/)
         write(un,*) 'min/max(h)_y = ',(/g%c(2)%hmin,g%c(2)%hmax/)
         write(un,*) 'min/max(h)_z = ',(/g%c(3)%hmin,g%c(3)%hmax/)
         write(un,*) 'min/max(dh)_x = ',(/g%c(1)%dhMin,g%c(1)%dhMax/)
         write(un,*) 'min/max(dh)_y = ',(/g%c(2)%dhMin,g%c(2)%dhMax/)
         write(un,*) 'min/max(dh)_z = ',(/g%c(3)%dhMin,g%c(3)%dhMax/)
         write(un,*) 'stretching_x = ',g%c(1)%dhMax-g%c(1)%dhMin
         write(un,*) 'stretching_y = ',g%c(2)%dhMax-g%c(2)%dhMin
         write(un,*) 'stretching_z = ',g%c(3)%dhMax-g%c(3)%dhMin
         write(un,*) ''
         write(un,*) 'stitches_x = ',g%st(1)%hmin,g%st(1)%hmax
         write(un,*) 'stitches_y = ',g%st(2)%hmin,g%st(2)%hmax
         write(un,*) 'stitches_z = ',g%st(3)%hmin,g%st(3)%hmax
         write(un,*) 'stitch_id_x = ',g%st(1)%hmin_id,g%st(1)%hmax_id
         write(un,*) 'stitch_id_y = ',g%st(2)%hmin_id,g%st(2)%hmax_id
         write(un,*) 'stitch_id_z = ',g%st(3)%hmin_id,g%st(3)%hmax_id
         write(un,*) 'defined = ',g%defined
       end subroutine

       subroutine print_Grid(g)
         implicit none
         type(grid), intent(in) :: g
         call export(g,6)
       end subroutine

       subroutine print_Grid_all(g)
         implicit none
         type(grid), intent(in) :: g
         call export_all(g,6)
       end subroutine

       end module