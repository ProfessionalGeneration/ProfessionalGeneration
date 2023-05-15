local Easing = {} do
    Easing.Out = {} do
        Easing.Out.Quad = function(x) -- main easing for scrolling
            return 1 - (1 - x) * (1 - x)
        end

        Easing.Out.Sine = function(x)
            return math.sin((x * math.pi) / 2)
        end

        Easing.Out.Quint = function(x)
            return 1 - math.pow(1 - x, 5)
        end

        Easing.Out.Cubic = function(x)
            return 1 - math.pow(1 - x, 3)
        end

        Easing.Out.Quart = function(x)
            return 1 - math.pow(1 - x, 4)
        end

        Easing.Out.Exponential = function(x)
            return x == 1 and 1 or 1 - math.pow(2, -10 * x)
        end

        Easing.Out.Circular = function(x)
            return math.sqrt(1 - math.pow(x - 1, 2))
        end

        Easing.Out.Back = function(x)
            return 3.70158 * math.pow(x - 1, 3) + 1.70158 * math.pow(x - 1, 2)
        end

        Easing.Out.Elastic = function(x)
            return x == 0 and 0
            or x == 1 and 1
            or math.pow(2, -10 * x) * math.sin((x * 10 - 0.75) * ((2 * math.pi) / 3)) + 1
        end

        Easing.Out.Bounce = function(x)
            local n1 = 7.5625;
            local d1 = 2.75;

            if x < 1 / d1 then
                return n1 * x * x
            end

            if x < 2 / d1 then
                x -= 1.5
                return n1 * (x / d1) * x + 0.75
            end

            if x < 2.5 / d1 then
                x -= 2.25
                return n1 * (x / d1) * x + 0.9375;
            end

            x -= 2.625
            return n1 * (x / d1) * x + 0.984375;
        end
    end

    Easing.In = {} do
        Easing.In.Sine = function(x)
            return 1 - math.cos((x * math.pi) / 2)
        end

        Easing.In.Quad = function(x)
            return x ^ 2
        end

        Easing.In.Cubic = function(x)
            return x ^ 3
        end

        Easing.In.Quart = function(x)
            return x ^ 4
        end

        Easing.In.Quint = function(x)
            return x ^ 5
        end

        Easing.In.Exponential = function(x)
            return x == 0 and 0 or math.pow(2, 10 * x - 10)
        end

        Easing.In.Circular = function(x)
            return 1 - math.sqrt(1 - math.pow(x, 2))
        end

        Easing.In.Back = function(x)
            return 2.70158 * x * x * x - 1.70158 * x * x
        end

        Easing.In.Elastic = function(x)
            return x == 0 and 0
            or x == 1 and 1
            or -math.pow(2, 10 * x - 10) * math.sin((x * 10 - 10.75) * ((2 * math.pi) / 3))
        end

        Easing.In.Bounce = function(x)
            return 1 - Easing.Out.Bounce(1 - x)
        end
    end

    Easing.InOut = {} do
        Easing.InOut.Sine = function(x)
            return -(math.cos(math.pi * x) - 1) / 2
        end

        Easing.InOut.Cubic = function(x)
            return x < 0.5 and 4 * x * x * x or 1 - math.pow(-2 * x + 2, 3) / 2
        end

        Easing.InOut.Quad = function(x)
            return x < 0.5 and 2 * x * x or 1 - math.pow(-2 * x + 2, 2) / 2
        end

        Easing.InOut.Quart = function(x)
            return x < 0.5 and 8 * x * x * x * x or 1 - math.pow(-2 * x + 2, 4) / 2
        end

        Easing.InOut.Quint = function(x)
            return x < 0.5 and 16 * x * x * x * x * x or 1 - math.pow(-2 * x + 2, 5) / 2
        end

        Easing.InOut.Exponential = function(x)
            return x == 0 and 0
            or x == 1 and 1
            or x < 0.5 and math.pow(2, 20 * x - 10) / 2
            or (2 - math.pow(2, -20 * x + 10)) / 2
        end

        Easing.InOut.Circular = function(x)
            return x < 0.5 and (1 - math.sqrt(1 - math.pow(2 * x, 2))) / 2
            or (math.sqrt(1 - math.pow(-2 * x + 2, 2)) + 1) / 2
        end

        Easing.InOut.Back = function(x)
            local c2 = 2.5949095;

            return x < 0.5 and (math.pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2
            or (math.pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2
        end

        Easing.InOut.Elastic = function(x)
            local c5 = (2 * math.pi) / 4.5;

            return x == 0 and 0
            or x == 1 and 1
            or x < 0.5 and -(math.pow(2, 20 * x - 10) * math.sin((20 * x - 11.125) * c5)) / 2
            or (math.pow(2, -20 * x + 10) * math.sin((20 * x - 11.125) * c5)) / 2 + 1
        end

        Easing.InOut.Bounce = function(x)
            return x < 0.5 and (1 - Easing.Out.Bounce(1 - 2 * x)) / 2
            or (1 + Easing.Out.Bounce(2 * x - 1)) / 2;
        end
    end
end

return Easing