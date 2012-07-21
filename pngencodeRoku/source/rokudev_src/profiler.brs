
' /' ***************************************************
'    Generic profiling object utility for BrightScript
'    Copyright 2011 Eric Lucas (Roku forum - MazeWizard/MazeWizzard) All Rights Reserved 
'    
'    Version 1.0 December 2011
'    
'    Provided for non-commercial use to the Roku BrightScript
'    developers forum.  No warranties express or implied.
'    Use at your own risk.  You may not resell this code.
'    
'    ***** Do not include it in any finished product. *****
'    ***** Remember to remove it and all calls before you publish.
'    ***** THE RESULTS ARE ONLY APPROXIMATIONS *****
'    ***** The author cannot be liable for any errors in this
'    ***** code nor effects on your programs and/or decisions.
'    ***** I have no idea how you will use this and have not
'    ***** gone through the rigorous testing required of a
'    ***** commercial product.
'    
'    Note:  This whole thing is complicated by the fact that
'    the timer is only 1 ms resolution.  Also, the Roku box is 
'    a multi-tasking box that preempts our routines and we have
'    no local timer so the time that the external processes
'    use gets randomly added to our numbers.  However, this is
'    still a very handy set of routines.
'    
'    Recursion must be handled by the programmer by making the item name
'    unique for each recursion or not profiling the recursive routine at all.
'    We do this so we don't have to keep a stack of timers.
'    
'    You may wish to use the <Profiler>.TimerTotalMilliseconds() routine rather
'    than the <roTimeSpan>.TotalMilliseconds() routine (or create a substitute)
'    since the profiler overhead is approximately subtracted out and won't mess
'    with your timings as much.
' *****************************************************'/
' the roArray indices are used as follows:
' I use a preprocessor and define these as constants, but this is the post-processed output
' Counter = 0
' totalMS = 1
' LastStart = 2
' Started = 3
' MaxMS = 4

' Usage:  Create a profiler object.  Call it as needed to profile chunks of code
'         name them whatever you wish.  The names must match between start/stop.
'   profiler = NewProfiler(1) 
'   profiler.start("Outer Block")
'       .....
'   profiler.start("This named chunk")
'   <a bunch of code here>
'   profiler.Stop("This named chunk")
'       .....
'   profiler.start("Another named chunk")
'   <more code here>
'   profiler.Stop("Another named chunk")
'       .....
'   profiler.IncrementCounter("Count of widget iterations")
'   profiler.Stop("Outer Block")
'
'   profile.DumpStats() ' outputs stats to the debug console
'
' Profiling real small/fast chunks of code is impractical since the timer resolution is 1 ms.
' The "Outer Block" item will include the time for the other items in this case.  Thus
' it doesn't make sense to add the "% of run" column (or other columns for that matter) as items
' can overlap. As noted above, recursive routines will require you to add an iteration counter
' to the name string as I don't wish to push/pop a stack of timers do and wish to
' detect the "item profiling already started" condition.

' I use a pre-processor with this... at least until Roku adds a DEFINE to the language.
' However, I've provided the post-processed output so you don't have to have a pre-processor
' to use it.  It is handy to have one tho.
' One trick is to have a pre-processor define for profiling in your code so we have
'   #Define @Profiler@ = g.Profiler
' in the code and change it to
'   #Define @Profiler@ = ' g.Profiler
' with a leading comment (note the ') to not profile (the g. is for my global aa)
' and the code would have @Profiler@.Start("foo") or @Profiler@.Stop("foo")
'

Function NewProfiler(Verbosity as integer) as Object
    this = {}

    this.TraceOn = Function()
        m.TimerStop()
        m.printTrace = true
        print "Trace [";t;"]>> On."
        m.TimerStart()
    End Function

    this.TraceOff = Function() 
        m.TimerStop()
        m.printTrace = false
        print "Trace [";t;"]>> Off"
        m.TimerStart()
    End Function
    
    this.IncrementCounter = Function(Name as string)
        m.TimerStop()
        Name2 = Name
        if Name2 = "" then Name2 = "**Empty**"
        data = m.countersaa.lookup(Name2)
        if data = invalid then
            data = 0
        end if 
       data = data + 1
        m.countersaa.AddReplace(Name2, data)
        m.TimerStart()
    End Function
    
    this.Start = Function(Name as string)
        m.TimerStop()

        m.TotalStarts = m.TotalStarts + 1
        Name2 = Name
        if Name2 = "" then Name2 = "**Empty**"
        data = m.profileaa.lookup(Name2)
        if data = invalid then
            data = CreateObject("roArray", 5, false)
            data[0] = 0
            data[1] = 0.0!
            data[3] = false
            data[4] = 0.0!
        endif
        if data[3] = true then
            Print "Profiler:  Start with start already active (Recursive?) for key = "; Name2
        else
            data[3] = True
            data[2] = m.TimerTotalMilliseconds()  
            
            m.profileaa.AddReplace(Name2, data)
        end if
        m.TimerStart()
    End Function

    this.Stop = function(Name as string)
        m.TimerStop()
        t = m.TimerTotalMilliseconds()
        Name2 = Name
        if Name2 = "" then Name2 = "**Empty**"

        data = m.profileaa.lookup(name2)
        if data <> invalid then
            if data[3] = true then
                data[0] = data[0] + 1
                data[3] = false

                tt = t - data[2] 
                if tt < 0 then
                    tt = 0
                end if
                data[1] = data[1] + tt 
                if tt > data[4] then
                    data[4] = tt
                end if
                if m.printTrace then
                    print "Trace [";t;"]>> ";name2; " added "; tt; " ms"
                end if
            else
                print "Profiler: Stop before start ignored for key = "; Name2
            end if
        else
            print "Profiler: Stop before start ignored for key = "; Name2
        end if
        m.TimerStart()
    End Function

    this.Zero = Function(Name as string)
        m.TimerStop()
        Name2 = Name
        if Name2 = "" then Name2 = "**Empty**"

        data = m.profileaa.lookup(name2)
        if data <> invalid then 
            if data[3] = true then
                data[0] = 0
                data[2] = m.TimerTotalMilliseconds()
                data[1] = 0!
                data[4]  = 0!
                if m.printTrace then
                    print "Trace [";t;"]>> ";name2; " zeroed WHILE RUNNING."
                end if
            else
                data[0] = 0
                data[2] = 0!
                data[1] = 0!
                data[4]  = 0!
                if m.printTrace then
                    print "Trace [";t;"]>> ";name2; " zeroed."
                end if
            end if
        else 
            if m.Verbosity > 0 then print "Trace [";t;"]>> Zero() called for non-existent ";name2; ".  Zero() irrelevant."
        end if
        m.TimerStart()
    End Function

    
    this.DumpStats = Function()
        m.TimerStop()
        Print
        Print "Profiled areas:"
        Print "Target Name                   "; "        Count  ", "         Total", " % of Run",  "Average             Max"
        Print "------------------------------"; "        -----  ", "        ------", "   ------",  "-------           -----"

        Runtime! = m.TimerTotalMilliseconds()
        totalTicks = 0
        for each ob in m.profileaa
            data = m.profileaa.lookup(ob)
            c = data[0]
            t1 = data[1]
            obst = ob + string(30, " ")
            obst = left(obst, 30)
            totalTicks = totalTicks + c
            flag = " "
            if data[3] = true then
                flag = "*"
            end if
            Print obst; flag; right(string(11, " ")+str(c), 12), m.FormatFloat(t1, 9),  m.FormatFloat(t1/Runtime!*100, 4);
            if c > 0 then 
                print m.FormatFloat(t1/c, 9);
            else 
                print m.FormatFloat(0, 9);
            end if
            print m.formatFloat(data[4], 11)

        end for
        Print "                              "; "     --------  "
        Print "* = start active, no stop yet "; right(string(13, " ") + str(totalTicks), 13); "  Remember that items can overlap/nest."
        print
        m.countersaa.Reset()
        if not m.countersaa.IsEmpty() then
            print "Counters:"
            print "Name                          ", "     Count"
            print "------------------------------", "     -----"
            for each ob in m.countersaa
                data = m.countersaa.lookup(ob)
                print left(ob + string(30, " "), 30), right(string(10, " ")+str(data), 10)
            end for
        end if
        print
        print "Profiler wall time to now: "; m.runtimer.TotalMilliseconds()
        print "Adjusted non-profiler time (clocked): "; Runtime!
        if m.Verbosity > 0 then print "Total Overhead thus far: "; m.totalOffset!
        print "All times are in ms.  End of profiler data dump."
        print
        m.TimerStart()
    End Function
    
    ' note: doesn't round and could truncate left or right so be careful
    this.FormatFloat = Function(f as float, decimalPointPos as Integer) as string
        
        if decimalPointPos < 1 then decimalPointPos = 1
        d = CreateObject("roString")
        
        i% = fix(f)
        i$ = str(i%)
        d = str(abs(f) - abs(i%))
        if d = " 0" then d = ".0"
        if left(d, 3) = " 0." then 
            d = right(d, len(d)-2)
        end if
        d = d.trim()+"000000"
        d = d.left(6)
        r$ =  right(string(30, " ")+i$, decimalPointPos-1) + d
        return r$
    End Function
    
    ' *** Warning *** These should not be called externally
    this.TimerStop = Function()
        if m.TimerRunning then
            m.timerStopPoint = m.runTimer.TotalMilliseconds() ' time after this line not incurred
            m.timerRunning = false 
        end if
    End Function
    
    ' We add the offset in start() because we usually do a stop/start
    this.TimerStart = Function()
        if m.timerRunning = false then
            m.TimerRunning = true
            m.totalOffset! = m.totalOffset! + m.TimerOverhead!
            m.totalOffset! = m.totalOffset! + (m.runtimer.TotalMilliseconds() - m.timerStopPoint)
        end if
    End Function
    ' ***
    
    ' this is usually called by our routines while timer is stopped
    this.TimerTotalMilliseconds = Function() as float
        if m.timerRunning = false then
            return m.timerStopPoint - m.totalOffset!
        end if
        return m.runTimer.TotalMilliseconds() - m.totalOffset!
    End Function
    
    this.GetTotal = Function(Name) as Float
        m.TimerStop()
        data = m.profileaa.Lookup(Name)
        if data <> invalid then
            t = data[1]
        else 
            t = 0.0!
        end if
        
        m.TimerStart()
        return t
    End Function

    this.GetCount = Function(Name) as Integer
        m.TimerStop()
        data = m.profileaa.Lookup(Name)
        if data <> invalid then
            t = data[0]
        else 
            t = 0
        end if
        
        m.TimerStart()
        return t
    End Function

    this.GetMax = Function(Name) as Float
        m.TimerStop()
        data = m.profileaa.Lookup(Name)
        if data <> invalid then
            t = data[4]
        else 
            t = 0.0!
        end if
        
        m.TimerStart()
        return t
    End Function
    
    This.CalibrateSS = Function(Foo as String)
        m.TimerStop()
        m.TimerStart()
    End Function
    
    this.Init = Function()

        if m.Verbosity < 0 then m.Verbosity = 0
        if m.Verbosity > 0 then print "Profiler Started. Keep off the remote.": Print  "Calibrating..."
        
        sleep(1000)  ' we sleep for a bit to allow the user to take the finger off the remote
        
        m.profileaa = CreateObject("roAssociativeArray")
        m.countersaa = CreateObject("roAssociativeArray")
        m.runtimer = CreateObject("roTimespan")

        m.printTrace = false
        m.totalOffset! = 0
        m.TimerOverhead! = 0
        m.timerRunning = true
        m.timerStopPoint = 0
        m.TotalStarts = 0
        m.runTimer.Mark()

        ' Collect before-calibration data.
        ' We only print it if Verbosity > 1 but we always collect it so that the aa is in the
        ' same state when we calibrate.  Otherwise, calibration may work differently with 
        ' different Verbosity settings/aa states.
        CName = "Before Calibration-10 ms sleep"
        for x = 1 to 100
            m.Start(CName)
            sleep(10)
            m.Stop(CName)
        end for
        t1 = m.GetTotal(CName)
       
        CName = "Before Calibration-1 ms sleep"
        For x = 1 to 1000
            m.Start(CName)
            sleep(1)
            m.Stop(CName)
        end for
        t2 = m.GetTotal(CName)
        
        tt% = CalibrateProfiler(m)
        t3 = m.GetTotal("Calibrate")
        m.profileaa.Delete("Calibrate")
        
        m.TimerOverhead! = (tt% - t3)/10000.0! ' <-- The whole point
        
        if m.TimerOverhead! < 0 then m.TimerOverhead! = 0.0!
        
        if m.Verbosity >= 1 then 
            'Do again, for the DumpStats() - this time with calibration set.
            CName = "After Calibration-1 ms sleep"
            For x = 1 to 1000
                m.Start(CName)
                sleep(1)
                m.Stop(CName)
            end for

            ' m.TraceOn()
            CName = "After Calibration-10 ms sleep"
            for x = 1 to 100
                m.Start(CName)
                sleep(10)
                m.Stop(CName)
            end for
            ' m.TraceOff()
            
            print
            m.DumpStats()
        end if
        
        if m.Verbosity > 0 then
            if m.Verbosity >= 1 then print "Estimated Timer start/stop overhead: "; m.TimerOverhead!
            print "Profiler Running.  Exiting init."
        end if

        m.profileaa.Clear()       
        m.totalOffset! = 0
        m.timerRunning = true
        m.timerStopPoint = 0
        m.runTimer.Mark()
    End Function
    
    this.Verbosity = Verbosity
    this.Init()

    return this
End Function

' OK, we need a figure for the timer start/stop overhead.
' We try for an estimate of the function call overhead into the profiler
' doing a stop/start of the timer.  This is what the profiler routines
' do.  So we're trying to eliminate the function call/return and timer
' start/stop from the timings.  With a multitasking box, garbage-collected
' variable space in BS and a 1 ms timer resolution this is only an estimate
' but its the best we can do.

' This routine must be called with the profiler.TimerOverhead! set to 0

Function CalibrateProfiler(prof as Object) as Integer
    t = CreateObject("roTimeSpan")
    tt% = 0
    for x = 1 to 200
        prof.Start("Calibrate")
        t.mark()
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo") ' 50 calls x 200 iterations = 10000 calls
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        prof.CalibrateSS("Foo"): prof.CalibrateSS("Foo")
        tt% = tt% + t.TotalMilliseconds()
        prof.Stop("Calibrate")
    end for
    return tt%
End Function