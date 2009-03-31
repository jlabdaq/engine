      SUBROUTINE h_fpp(ABORT,err)
*--------------------------------------------------------
*    Hall C  HMS Focal Plane Polarimeter Code
*
*  Purpose: analyze FPP portion of HMS event
* 
*  Created by Frank R. Wesselmann,  February 2004
*
*--------------------------------------------------------

      IMPLICIT NONE

      include 'gen_detectorids.par'
      include 'gen_decode_common.cmn'
      include 'gen_event_info.cmn'
      INCLUDE 'hms_data_structures.cmn'
      INCLUDE 'hms_fpp_params.cmn'
      INCLUDE 'hms_fpp_event.cmn'

      character*13 here
      parameter (here= 'h_fpp')

      logical ABORT
      character*(*) err

      integer*4 iset


      ABORT= .FALSE.
      err= ' '

c      write(*,*)'In h_fpp.f with hsnum_fptrack =',hsnum_fptrack
      if (hsnum_fptrack.le.0) return    ! No good HMS track
*     * note that the above value is determined in h_select_best_track
*     * so we have to wait until after it is called before we do the FPP!

c      write(*,*)'Calling fpp_tracking -> event=',gen_event_id_number

*     * do tracking in each set of chambers separately
      do iset=1, H_FPP_N_DCSETS
c         write(*,*)'Calling fpp_tracking -> event=',gen_event_id_number
c        write(*,*)'iset,layers,min = ',iset,HFPP_Nlayershit_set(iset),
c     &   HFPP_minsethits
         if (HFPP_Nlayershit_set(iset) .ge. HFPP_minsethits) then
            if(hfppuseajptracking.ne.0) then
               call h_fpp_tracking_ajp(iset,abort,err)
            else
               call h_fpp_tracking(iset,ABORT,err)
            endif
            if (ABORT) then
               call g_add_path(here,err)
               return
            endif
            
c     if tracks were found and flag is set, do best track selection
c     in each FPP for the gep ntuple. Loop over filled track arrays 
c     and set the variable hfpp_best_track(fpp1/2)
            if(hselectfpptrackprune.ne.0.and.hfpp_n_tracks(iset).gt.0 )
     $           then 
c     choose best FPP track using prune tests
               call h_fpp_select_best_track_prune(iset,abort,err)
               if (ABORT) then
                  call g_add_path(here,err)
                  return
               endif
            endif
         endif
      enddo  !iset

*     * do statistical analysis, e.g. efficiencies
      call h_fpp_statistics(ABORT,err)
      if (ABORT) then
        call g_add_path(here,err)
        return
      endif


      RETURN
      END
