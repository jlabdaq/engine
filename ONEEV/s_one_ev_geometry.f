      subroutine s_one_ev_geometry
*
* This routine will get the detector position and size information from CTP,
* then use this information for defining the different GEANT geometry structures
*
* August, 1994, Pat Welch, Oregon State University, tpw@physics.orst.edu
*
* Note: Subdivided volumes won't work for doing coordinate transforms.  Or
*	at least I didn't see a method around them.  So I have defined all
*	the subvolumes explicitly. (TPW)
*
* Modified from HMS version, h_one_ev_geometry, March 1995 by
* Derek van Westrum (vanwestr@cebaf.gov)
*
* $Log$
* Revision 1.1  1995/07/31 15:23:38  cdaq
* Initial revision
* h_one_ev_geometry.f,v $

      implicit none

      include 'sos_data_structures.cmn'
      include 'sos_geometry.cmn'
      include 'sos_calorimeter.cmn'
      include 'sos_scin_parms.cmn'
      include 'sos_one_ev.par'

      integer SHUTMEDIA                 ! non-sensitive tracking media
      integer DETMEDIA                  ! sensitive tracking media
      parameter (SHUTMEDIA = 1, DETMEDIA = 2)
      real*4 hodoscale
      parameter (hodoscale = 3.)
      real*4 wcscale
*      parameter (wcscale = 5.)
      parameter (wcscale = 1.)
      real*4 xwirelength                   
      real*4 ywirelength                   
      real*4 uwirelength
      real*4 vwirelength

      character*5 scinname 
      character*5 layername
      character*5 planename
      character*5 wirename
      character*5 chamber
      character*5 plane
      character*5 wire
      character*5 blockname
      integer isector
      integer iplane
      integer iwire
      integer ichamber
      integer ilayer
      integer irow

      integer ivolu			! internal volume number
      real par(10)			! geometry parameters
      real x, y, z			! offset position for placement of dets
      integer i                         ! index variable
      real*4 raddeg
      parameter (raddeg = 3.14159265/180.)

* First define two general media that everything is made of
* one is insensitive, and the other is sensitive

      call gstmed (SHUTMEDIA, 'air', 15, 0, 0,0.,20.,1.,0.5,1.,1.,0,0)
      call gstmed (DETMEDIA, 'det', 15, 1, 0,0.,20.,1.,0.5,1.,1.,0,0)

* Now define the mother volume that the detectors sit in
      par(1) = SHUT_WIDTH / 2.          ! half width in x of mother volume
      par(2) = SHUT_WIDTH / 2.          ! half width in y of mother volume
      par(3) = SHUT_HEIGHT / 2.         ! half height in z of mother volume
      call g_ugsvolu ('SHUT', 'BOX ', SHUTMEDIA, par, 3, ivolu)
      call gsatt ('SHUT', 'SEEN', 0)	! can't see the hut

* Define some wire lengths..

      xwirelength = 40.0
      ywirelength = 60.0
      uwirelength = xwirelength / SIN(sdc_alpha_angle(1))
      vwirelength = xwirelength / SIN(sdc_alpha_angle(2))


* Now define the wire chambers as a collection of planes
* First the U and V planes.
*
      par(1) = ywirelength/2.
      par(2) = xwirelength/2.
      par(3) = wcscale * (sdc_zpos(2) - sdc_zpos(1))/ 2. ! half width of chamber planes
      do ichamber = 1,2
         do iplane = 1,2
           write(planename,'(a,a,a,a)') "W",char(64+ichamber),char(64+iplane),"U"
           call g_ugsvolu (planename, 'BOX ', DETMEDIA, par, 3, ivolu)
           write(planename,'(a,a,a,a)') "W",char(64+ichamber),char(64+iplane),"V"
           call g_ugsvolu (planename, 'BOX ', DETMEDIA, par, 3, ivolu)
         enddo
       enddo
*
* Now do the X planes. 
*
      par(1) = ywirelength/2.
      par(2) = xwirelength/2.
      par(3) = wcscale * (sdc_zpos(2) - sdc_zpos(1))/ 2. ! half width of chamber planes
      do ichamber = 1,2
         do iplane = 1,2
           write(planename,'(a,a,a,a)') "W",char(64+ichamber),char(64+iplane),"X"
           call g_ugsvolu (planename, 'BOX ', DETMEDIA, par, 3, ivolu)
         enddo
       enddo

! make a volume for 6 planes.  The size here should be cool. DVW 18 jul 95
      par(1) = ywirelength/2.
      par(2) = xwirelength/2.
      par(3) = wcscale * (6./5. * (sdc_zpos(6) - sdc_zpos(1))) / 2.
      call g_ugsvolu ('WCHA', 'BOX ', DETMEDIA, par, 3, ivolu) ! Wire chamber
      call g_ugsvolu ('WCHB', 'BOX ', DETMEDIA, par, 3, ivolu) ! Wire chamber

* Now place the planes within the wire chamber.  Start with U
      z = - wcscale * (5. / 2.) * (sdc_zpos(2) -sdc_zpos(1))
      call gspos ('WAAU', 1, 'WCHA', 0., 0., z, 0, 'ONLY') ! U plane
      z = - wcscale * (3. / 2.) * (sdc_zpos(2) -sdc_zpos(1))
      call gspos ('WABU', 1, 'WCHA', 0., 0., z, 0, 'ONLY') ! U plane
      z = - wcscale * (5. / 2.) * (sdc_zpos(2) -sdc_zpos(1))
      call gspos ('WBAU', 1, 'WCHB', 0., 0., z, 0, 'ONLY') ! U plane
      z = - wcscale * (3. / 2.) * (sdc_zpos(2) -sdc_zpos(1))
      call gspos ('WBBU', 1, 'WCHB', 0., 0., z, 0, 'ONLY') ! U plane
*
      z = - wcscale * (1. / 2.) * (sdc_zpos(2) -sdc_zpos(1))
      call gspos ('WAAX', 1, 'WCHA', 0., 0., z, 0, 'ONLY') ! X plane
      z =   wcscale * (1. / 2.) * (sdc_zpos(2) -sdc_zpos(1))
      call gspos ('WABX', 1, 'WCHA', 0., 0., z, 0, 'ONLY') ! X plane
      z = - wcscale * (1. / 2.) * (sdc_zpos(2) -sdc_zpos(1))
      call gspos ('WBAX', 1, 'WCHB', 0., 0., z, 0, 'ONLY') ! X plane
      z =   wcscale * (1. / 2.) * (sdc_zpos(2) -sdc_zpos(1))
      call gspos ('WBBX', 1, 'WCHB', 0., 0., z, 0, 'ONLY') ! X plane
*
      z =   wcscale * (3. / 2.) * (sdc_zpos(2) -sdc_zpos(1))
      call gspos ('WAAV', 1, 'WCHA', 0., 0., z, 0, 'ONLY') ! V plane
      z =   wcscale * (5. / 2.) * (sdc_zpos(2) -sdc_zpos(1))
      call gspos ('WABV', 1, 'WCHA', 0., 0., z, 0, 'ONLY') ! V plane
      z =   wcscale * (3. / 2.) * (sdc_zpos(2) -sdc_zpos(1))
      call gspos ('WBAV', 1, 'WCHB', 0., 0., z, 0, 'ONLY') ! V plane
      z =   wcscale * (5. / 2.) * (sdc_zpos(2) -sdc_zpos(1))
      call gspos ('WBBV', 1, 'WCHB', 0., 0., z, 0, 'ONLY') ! V plane

* Now place the wire chambers in the mother volume
*
      x = sdc_xcenter(1)
      y = - sdc_ycenter(1)
      z = sdc_1_zpos
      call gspos ('WCHA', 1, 'SHUT', x, y, z, 0, 'ONLY') ! upper chamber
      x = sdc_xcenter(2)
      y = - sdc_ycenter(2)
      z = sdc_2_zpos
      call gspos ('WCHB', 1, 'SHUT', x, y, z, 0, 'ONLY') ! bottom chamber
*
* Define the individual wire cells
* See the file "displaynumbering.help" for a description of the numbering of the
* various detector elements
*
*****
*UUUU
*****
      par(1) = sdc_pitch(1) / 2./1000.        ! make the cells "wire" thin
      par(2) = uwirelength/2.
      par(3) = (sdc_zpos(2) - sdc_zpos(1))/ 2./1000. ! half width of chamber planes
*
* First define all the "boxes" for all the U wires in both chambers...
*
      do ichamber=1,2
       do isector=1,4
          do iwire = 1,24
            write (wire,'(a,a,a,a)') char(64 + ichamber),'U',
     $             char(64 + isector),char(64 + iwire)
            call g_ugsvolu (wire, 'BOX ', DETMEDIA, par, 3, ivolu) ! U cell
            call gsatt (wire, 'SEEN', 0) ! can't see the wire cells
          enddo
       enddo
      enddo
*
      par(1) = sdc_pitch(1) / SIN(sdc_alpha_angle(1))        
*
* Now position the U wires plane by plane...
      do ichamber=1,2
         x = -(sdc_nrwire(1) + 1.) / 2. * par(1)
         do isector=1,2
            do iwire = 1,24
               write (plane,'(a,a,a,a)') 'W',char(64 + ichamber),'AU'
               write (wire,'(a,a,a,a)') char(64 + ichamber),'U',
     $             char(64 + isector),char(64 + iwire)
               x = x + par(1)
               call gspos (wire, 1, plane, x, 0., 0., 3, 'ONLY')
            enddo
         enddo
         x = -(sdc_nrwire(1) + 1.) / 2. * par(1)
         do isector = 3,4
            do iwire = 1,24
               write (plane,'(a,a,a,a)') 'W',char(64 + ichamber),'BU'
               write (wire,'(a,a,a,a)') char(64 + ichamber),'U',
     $              char(64 + isector),char(64 + iwire)
               x = x + par(1)
               call gspos (wire, 1, plane, x, 0., 0., 3, 'ONLY')
            enddo
         enddo
      enddo
*
*
* Now position the X wires plane by plane...
*****
*XXX
*****
      par(1) = sdc_pitch(3) / 2. /1000.       ! half width of cell
      par(2) = xwirelength/2.             ! the length of the xwirelengths
      par(3) = (sdc_zpos(4) - sdc_zpos(3))/ 2./1000. ! half width of chamber planes
*
* First define all the "boxes" for all the X wires in both chambers...
*
      do ichamber=1,2
       do isector=1,8
          do iwire = 1,16
            write (wire,'(a,a,a,a)') char(64 + ichamber),'X',
     $             char(64 + isector),char(64 + iwire)
            call g_ugsvolu (wire, 'BOX ', DETMEDIA, par, 3, ivolu) ! X cell
            call gsatt (wire, 'SEEN', 0) ! can't see the wire cells
          enddo
       enddo
      enddo
*
      par(1) = sdc_pitch(3)
*
* Now position the X wires plane by plane...
      do ichamber=1,2
         x = -(sdc_nrwire(3) + 1.) / 2. * par(1) 
         do isector=1,4
            do iwire = 1,16
               write (plane,'(a,a,a,a)') 'W',char(64 + ichamber),'AX'
               write (wire,'(a,a,a,a)') char(64 + ichamber),'X',
     $             char(64 + isector),char(64 + iwire)
               x = x + par(1)
               call gspos (wire, 1, plane, x, 0., 0., 0, 'ONLY')
            enddo
         enddo
         x = -(sdc_nrwire(3) + 1.) / 2. * par(1)
         do isector = 5,8
            do iwire = 1,16
               write (plane,'(a,a,a,a)') 'W',char(64 + ichamber),'BX'
               write (wire,'(a,a,a,a)') char(64 + ichamber),'X',
     $              char(64 + isector),char(64 + iwire)
               x = x + par(1)
               call gspos (wire, 1, plane, x, 0., 0., 0, 'ONLY')
            enddo
         enddo
      enddo
*
*
*****
*VVVV
*****
      par(1) = sdc_pitch(5) / 2./1000.        ! half width of cell
      par(2) = vwirelength/2.
      par(3) = (sdc_zpos(6) - sdc_zpos(5))/ 2./1000. ! half width of chamber planes
*
* First define all the "boxes" for all the V wires in both chambers...
*
      do ichamber=1,2
       do isector=1,4
          do iwire = 1,24
            write (wire,'(a,a,a,a)') char(64 + ichamber),'V',
     $             char(64 + isector),char(64 + iwire)
            call g_ugsvolu (wire, 'BOX ', DETMEDIA, par, 3, ivolu) ! V cell
            call gsatt (wire, 'SEEN', 0) ! can't see the wire cells
          enddo
       enddo
      enddo
*
      par(1) = sdc_pitch(5) / SIN(sdc_alpha_angle(5))        

* Now position the V wires plane by plane...
      do ichamber=1,2
         x = -(sdc_nrwire(5) + 1.) / 2. * par(1)
         do isector=1,2
            do iwire = 1,24
               write (plane,'(a,a,a,a)') 'W',char(64 + ichamber),'AV'
               write (wire,'(a,a,a,a)') char(64 + ichamber),'V',
     $             char(64 + isector),char(64 + iwire)
               x = x + par(1)
               call gspos (wire, 1, plane, x, 0., 0., 4, 'ONLY')
            enddo
         enddo
         x = -(sdc_nrwire(5) + 1.) / 2. * par(1)
         do isector = 3,4
            do iwire = 1,24
               write (plane,'(a,a,a,a)') 'W',char(64 + ichamber),'BV'
               write (wire,'(a,a,a,a)') char(64 + ichamber),'V',
     $              char(64 + isector),char(64 + iwire)
               x = x + par(1)
               call gspos (wire, 1, plane, x, 0., 0., 4, 'ONLY')
            enddo
         enddo
      enddo
*
*
* Now define the hodoscope layers
* See the file "displaynumbering.help" for a description of the numbering of the
* various detector elements

! half width of hodoscope in x
      par(1) = sscin_1x_size * LOWER_HODO_X_PADDLES / 2.
! half width of hodoscope in y
      par(2) = sscin_1y_size * LOWER_HODO_Y_PADDLES / 2.
! half thickness of hodoscope in z, times 2 because of stagger
      par(3) = HODO_THICKNESS * hodoscale
      call g_ugsvolu ('HDX1', 'BOX ', DETMEDIA, par, 3, ivolu) ! X plane hodo
      call g_ugsvolu ('HDY1', 'BOX ', DETMEDIA, par, 3, ivolu) ! Y plane hodo

! half width of hodoscope in x
      par(1) = sscin_2x_size * UPPER_HODO_X_PADDLES / 2.
! half width of hodoscope in y
      par(2) = sscin_2y_size * UPPER_HODO_Y_PADDLES / 2.
! half thickness of hodoscope in z, times 2 because of stagger
      par(3) = HODO_THICKNESS * hodoscale
      call g_ugsvolu ('HDX2', 'BOX ', DETMEDIA, par, 3, ivolu) ! X plane hodo
      call g_ugsvolu ('HDY2', 'BOX ', DETMEDIA, par, 3, ivolu) ! Y plane hodo

! box for front hodos
! half width of hodoscope in x
      par(1) = sscin_1x_size * LOWER_HODO_X_PADDLES / 2.
! half width of hodoscope in y
      par(2) = sscin_1y_size * LOWER_HODO_Y_PADDLES / 2.
      par(3) = HODO_THICKNESS*hodoscale + (sscin_1y_zpos-sscin_1x_zpos)/2.
      call g_ugsvolu ('HOD1', 'BOX ', DETMEDIA, par, 3, ivolu) ! hodoscope box
      call gsatt ('HOD1', 'SEEN', 0)	! can't see the hodo box

! box for back hodos
! half width of hodoscope in x
      par(1) = sscin_2x_size * UPPER_HODO_X_PADDLES / 2.
! half width of hodoscope in y
      par(2) = sscin_2y_size * UPPER_HODO_Y_PADDLES / 2.
      par(3) = HODO_THICKNESS*hodoscale + (sscin_2y_zpos-sscin_2x_zpos)/2.
      call g_ugsvolu ('HOD2', 'BOX ', DETMEDIA, par, 3, ivolu) ! hodoscope box
      call gsatt ('HOD2', 'SEEN', 0)	! can't see the hodo box
*                                         added by Derek
*
      x = HODO_LOWER_X_OFFSET
      y = HODO_LOWER_Y_OFFSET
      z = sscin_1x_zpos
      call gspos ('HOD1', 1, 'SHUT', x, y, z, 0, 'ONLY') ! lower hodo
      x = HODO_UPPER_X_OFFSET
      y = HODO_UPPER_Y_OFFSET
      z = sscin_2x_zpos
      call gspos ('HOD2', 1, 'SHUT', x, y, z, 0, 'ONLY') ! upper hodo

      z= -(HODO_THICKNESS*hodoscale + (sscin_1y_zpos-sscin_1x_zpos))/2.
      call gspos ('HDX1', 1, 'HOD1', 0., 0., z, 0, 'ONLY') ! X plane
      call gspos ('HDY1', 1, 'HOD1', 0., 0., -z, 0, 'ONLY') ! Y plane
      z= -(HODO_THICKNESS*hodoscale + (sscin_2y_zpos-sscin_2x_zpos))/2.
      call gspos ('HDX2', 1, 'HOD2', 0., 0., z, 0, 'ONLY') ! X plane
      call gspos ('HDY2', 1, 'HOD2', 0., 0., -z, 0, 'ONLY') ! Y plane

* Now define the strips for the hodoscopes

      x = (LOWER_HODO_X_PADDLES + 1.) * sscin_1x_size / 2. ! starting loci
      do i = 1, LOWER_HODO_X_PADDLES
        x = x - sscin_1x_size
        write (scinname,'(a,a)') 'H1X',char(64 + i)
*        call gspos ('HOX1', i, 'HDX1', x, 0., 0., 0, 'ONLY')
        par(1) = sscin_1x_size / 2. ! half width of X strips
        par(2) = sscin_1y_size * LOWER_HODO_Y_PADDLES / 2.
                                       ! half width of hodoscope in y
        par(3) = HODO_THICKNESS * hodoscale / 2. !half thickness of hodoscope in z
        call g_ugsvolu (scinname, 'BOX ', DETMEDIA, par, 3, ivolu) ! X plane hodo
        call gspos (scinname, i, 'HDX1', x, 0., 0., 0, 'ONLY')
      enddo
      y = (LOWER_HODO_Y_PADDLES + 1.) * sscin_1y_size / 2. ! starting loci
      do i = 1, LOWER_HODO_Y_PADDLES
        y = y - sscin_1y_size
        write (scinname,'(a,a)') 'H1Y',char(64 + i)
        par(1) = sscin_1x_size * LOWER_HODO_X_PADDLES / 2.
                                        ! half width of hodoscope in x
        par(2) = sscin_1y_size / 2.	! half width of X strips
        par(3) = HODO_THICKNESS * hodoscale / 2. !half thickness of hodoscope in z
        call g_ugsvolu (scinname, 'BOX ', DETMEDIA, par, 3, ivolu) ! Y plane hodo
        call gspos (scinname, i, 'HDY1', 0., y, 0., 0, 'ONLY')
      enddo
      x = (UPPER_HODO_X_PADDLES + 1.) * sscin_2x_size / 2. ! starting loci
      do i = 1,UPPER_HODO_X_PADDLES
        x = x - sscin_2x_size
        write (scinname,'(a,a)') 'H2X',char(64 + i)
        par(1) = sscin_2x_size / 2. ! half width of X strips
        par(2) = sscin_2y_size * UPPER_HODO_Y_PADDLES / 2.
                                          ! half width of hodoscope in y
        par(3) = HODO_THICKNESS * hodoscale / 2. !half thickness of hodoscope in z
        call g_ugsvolu (scinname, 'BOX ', DETMEDIA, par, 3, ivolu) ! X plane hodo
        call gspos (scinname, i, 'HDX2', x, 0., 0., 0, 'ONLY')
      enddo
      y = (UPPER_HODO_Y_PADDLES + 1.) * sscin_2y_size / 2. ! starting loci
      do i = 1, UPPER_HODO_Y_PADDLES
        y = y - sscin_2y_size
        write (scinname,'(a,a)') 'H2Y',char(64 + i)
        par(1) = sscin_2x_size * UPPER_HODO_X_PADDLES / 2.
                                        ! half width of hodoscope in x
        par(2) = sscin_2y_size / 2.	! half width of X strips
        par(3) = HODO_THICKNESS * hodoscale / 2. !half thickness of hodoscope in z
        call g_ugsvolu (scinname, 'BOX ', DETMEDIA, par, 3, ivolu) ! Y plane hodo
        call gspos (scinname, i, 'HDY2', 0., y, 0., 0, 'ONLY')
      enddo

* Now define the shower detector
* See the file "displaynumbering.help" for a description of the numbering of the
* various detector elements

! half width of the shower in x
      par(1) = smax_cal_rows * scal_block_zsize / 2.
! half width of the shower in y
      par(2) = scal_block_ysize / 2.
! half height of the shower detector
      par(3) = smax_cal_columns * scal_block_xsize / 2.
      call g_ugsvolu ('SHOW', 'BOX ', DETMEDIA, par, 3, ivolu)
      x = SHOWER_X_OFFSET 
      y = SHOWER_Y_OFFSET
      z = scal_1pr_zpos + smax_cal_columns*scal_block_xsize/2.
      call gspos ('SHOW', 1, 'SHUT', x, y, z, 0, 'ONLY')
      call gsatt ('SHOW','SEEN',0)

! half width of the shower in x
      par(1) = smax_cal_rows * scal_block_zsize / 2.
! half width of the shower in y
      par(2) = scal_block_ysize / 2.
! half height of the shower detector
      par(3) = scal_block_xsize / 2.
      call g_ugsvolu ('LAY1', 'BOX ', DETMEDIA, par, 3, ivolu)
      call g_ugsvolu ('LAY2', 'BOX ', DETMEDIA, par, 3, ivolu)
      call g_ugsvolu ('LAY3', 'BOX ', DETMEDIA, par, 3, ivolu)
      call g_ugsvolu ('LAY4', 'BOX ', DETMEDIA, par, 3, ivolu)

      z = -(smax_cal_columns + 1.) / 2. * scal_block_xsize
      z = z + scal_block_xsize
      call gspos('LAY1', 1, 'SHOW', 0., 0., z, 0, 'ONLY')
      z = z + scal_block_xsize
      call gspos('LAY2', 1, 'SHOW', 0., 0., z, 0, 'ONLY')
      z = z + scal_block_xsize
      call gspos('LAY3', 1, 'SHOW', 0., 0., z, 0, 'ONLY')
      z = z + scal_block_xsize
      call gspos('LAY4', 1, 'SHOW', 0., 0., z, 0, 'ONLY')

      par(1) = scal_block_zsize / 2.	! half width of a block
      par(2) = scal_block_ysize / 2.	! half length of a block
      par(3) = scal_block_xsize / 2.	! half height of a block
      do ilayer =1,SMAX_CAL_COLUMNS
         do irow = 1,SMAX_CAL_ROWS
            write (blockname,'(a,i1,a)') 'BL',ilayer,char(64 + irow)
            call g_ugsvolu (blockname, 'BOX ', DETMEDIA, par, 3, ivolu)
         enddo
      enddo
*
      do ilayer =1,SMAX_CAL_COLUMNS
         x =  (smax_cal_rows - 1.) / 2. * scal_block_zsize
         do irow = 1,SMAX_CAL_ROWS
            write (blockname,'(a,i1,a)') 'BL',ilayer,char(64 + irow)
            write (layername,'(a,i1)') 'LAY',ilayer
            call gspos(blockname, 1, layername, x, 0., 0., 0, 'ONLY')
            x = x - scal_block_zsize
         enddo
      enddo

*

      end