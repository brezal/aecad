require! './lib/snap-move': {snap-move}

class Line
    (@scope, point) ->
        @line = new @scope.Path!
        if point
            @line.add(point)
        @tolerance = 10
        @color = 'white'

    moving-point: ~
        -> @line?segments[*-1].point

    last-point: ~
        -> @line?segments[*-2].point

    color: ~
        (val) -> @line.strokeColor = val;

    add-segment: (point) ->
        @line.add point

    follow: (point) ->
        snap = snap-move @last-point, point, {
            tolerance: @tolerance / @scope.view.zoom
            lock: @lock
        }
        @moving-point.set snap.point

    remove-last-segment: ->
        @line?.segments[*-1].remove!

    end: ->
        @remove-last-segment!
        if @line.segments.length < 2
            @line.remove!

export LineTool = (scope) ->
    line = null

    freehand = new scope.Tool!
        ..onMouseDown = (event) ~>
            scope.use-layer \gui
            unless line
                line := new Line scope, event.point
            line.add-segment event.point

        ..onMouseMove = (event) ->
            line?.follow event.point

        ..onKeyDown = (event) ~>
            switch event.key
            | \escape =>
                # Press Esc to cancel a cache
                line?.end!
                line := null
            | \shift =>
                line?lock = yes

        ..onKeyUp = (event) ->
            switch event.key
            | \shift =>
                line?lock = no 
