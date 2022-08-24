import Toybox.WatchUi;
import Toybox.System;

class CruiseView extends WatchUi.View 
{
    hidden var _gpsWrapper;
	hidden var _timer;
	hidden var _isAvgSpeedDisplay = true;
	hidden var _displayMode = 0;
	hidden var _cruiseViewDc;

    function initialize(gpsWrapper, cruiseViewDc) 
    {
        View.initialize();
        _gpsWrapper = gpsWrapper;
        _cruiseViewDc = cruiseViewDc;
        _timer = new Timer.Timer();
    }

	// SetUp timer on show to update every second
    //
    function onShow() 
    {
    	
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
        WatchUi.requestUpdate();
    }    

    // Update the view
    //
    function onUpdate(dc) 
    {   
    	_cruiseViewDc.ClearDc(dc);
    
    	// Display current time
    	//
        var clockTime = System.getClockTime();        
        _cruiseViewDc.PrintTime(dc, clockTime);
        
        // Display speed and bearing if GPS available
        //
        var gpsInfo = _gpsWrapper.GetGpsInfo();
        if (gpsInfo.Accuracy > 0)
        {
        	_cruiseViewDc.PrintSpeed(dc, gpsInfo.SpeedKnot);
        	_cruiseViewDc.PrintBearing(dc, gpsInfo.BearingDegree);
        	_cruiseViewDc.PrintMaxSpeed(dc, gpsInfo.MaxSpeedKnot);	
        	_cruiseViewDc.PrintTotalDistance(dc, gpsInfo.TotalDistance);
        	
        	if (_displayMode == 0)
        	{
        		_cruiseViewDc.PrintAvgBearing(dc, gpsInfo.AvgBearingDegree);
        	} 
        	else if (_displayMode == 1)
        	{
        		_cruiseViewDc.PrintAvgSpeed(dc, gpsInfo.AvgSpeedKnot);
        	} 

        	// Display speed gradient. If current speed > avg speed then trend is positive and vice versa.
        	//
        	_cruiseViewDc.DisplaySpeedTrend(dc, gpsInfo.SpeedKnot - gpsInfo.AvgSpeedKnot, gpsInfo.SpeedKnot); 
        }
        
        _cruiseViewDc.DisplayState(dc, gpsInfo.Accuracy, gpsInfo.IsRecording, gpsInfo.LapCount);
        
        _cruiseViewDc.DrawGrid(dc);
    }
    
    function SwitchNextMode()
    {
    	_displayMode += 1;
    	_displayMode = _displayMode % 2;
    }
}