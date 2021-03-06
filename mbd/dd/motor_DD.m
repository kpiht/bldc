SimParams.PwmFrq = 30.0e3;
SimParams.Ts = 1.0e-5;

MotorParams.R = 23.6347; % Resistance.
MotorParams.L = 0.02395e-1; % Inductance.
MotorParams.K = 0.0155; % Torque Constant.
MotorParams.Kf = 7.5434e-7; % Damping.
MotorParams.J = 8.6337e-8; % Inertia.
MotorParams.AccMax = 1e4 * 180 / pi;
MotorParams.PPR = 400; % Encoder pulses / rev.

CtrlParams.TsIfbk = 1e-3;
CtrlParams.IfbkKi = 4 * MotorParams.R / CtrlParams.TsIfbk;
CtrlParams.IfbkKp = 4 * MotorParams.L / CtrlParams.TsIfbk;

CtrlParams.TsSpd = 0.05;
CtrlParams.SpdKi = 4 * MotorParams.Kf / MotorParams.K / CtrlParams.TsSpd;
CtrlParams.SpdKp = 4 * MotorParams.J / MotorParams.K / CtrlParams.TsSpd;

CtrlParams.TsPos = 0.3;
CtrlParams.PosKp = (4 / CtrlParams.TsPos);
CtrlParams.PosKi = 0.0;

SmDiffParams.AccMax = 9e4;
SmDiffParams.Ki = 1.1 * SmDiffParams.AccMax;
SmDiffParams.Kp = sqrt(SmDiffParams.AccMax);
