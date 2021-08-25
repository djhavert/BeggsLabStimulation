classdef Event
  properties
    time {mustBeInteger, mustBeNonnegative};
    channel {mustBeInteger};
    eventID {mustBeInteger, mustBeNonZero};
  end
end