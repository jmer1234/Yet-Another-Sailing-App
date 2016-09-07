using Toybox.WatchUi as Ui;
using Toybox.System as Sys;
using Toybox.ActivityRecording as Fit;

class CruiseView extends Ui.View 
{
    hidden var _gpsWrapper;
	hidden var _timer;

    hidden var _lastKnownAccuracy = 0;

    function initialize(gpsWrapper) 
    {
        View.initialize();
        _gpsWrapper = gpsWrapper;
    }

	// SetUp timer on show to update every second
    //
    function onShow() 
    {
    	_timer = new Timer.Timer();
    	_timer.start(method(:onTimerUpdate), 1000, true);
    }

    // Stop timer then hide
    //
    function onHide() 
    {
        _timer.stop();
    }
    
    // Refresh view every second
    //
    function onTimerUpdate()
    {
        Ui.requestUpdate();
    }    

    // Update the view
    //
    function onUpdate(dc) 
    {   
    	DcWrapper.ClearDc(dc);
    
    	// Display current time
    	//
        var clockTime = Sys.getClockTime();        
        DcWrapper.PrintTime(dc, clockTime);
        
        // Display speed and bearing if GPS available
        //
        var gpsInfo = _gpsWrapper.GetGpsInfo();
        _lastKnownAccuracy = gpsInfo.Accuracy;
        if (_lastKnownAccuracy > 0)
        {
        	DcWrapper.PrintSpeed(dc, gpsInfo.SpeedKnot);
        	DcWrapper.PrintBearing(dc, gpsInfo.BearingDegree);
        	DcWrapper.PrintMaxSpeed(dc, gpsInfo.MaxSpeedKnot);	
        	DcWrapper.PrintAvgSpeed(dc, gpsInfo.AvgSpeedKnot);
        	
        	// Display speed gradient. If current speed > avg speed then trend is positive and vice versa.
        	//
        	DcWrapper.DisplaySpeedTrend(dc, gpsInfo.SpeedKnot - gpsInfo.AvgSpeedKnot); 
        }
        
        DcWrapper.DisplayState(dc, gpsInfo.Accuracy, gpsInfo.IsRecording, gpsInfo.LapCount);
        
        DcWrapper.DrawGrid(dc);
    }

}