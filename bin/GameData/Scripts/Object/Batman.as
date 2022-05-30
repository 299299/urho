// ==============================================
//
//    Bruce Class
//
// ==============================================

class BatmanStandState : PlayerStandState
{
    BatmanStandState(Character@ c)
    {
        super(c);
        AddMotion(BATMAN_MOVEMENT_GROUP + "Stand_Idle");
        AddMotion(BATMAN_MOVEMENT_GROUP + "Stand_Idle_01");
        AddMotion(BATMAN_MOVEMENT_GROUP + "Stand_Idle_02");
    }
};

class BatmanRunState : PlayerRunState
{
    BatmanRunState(Character@ c)
    {
        super(c);
        SetMotion(BATMAN_MOVEMENT_GROUP + "Run_Forward");
    }
};

class BatmanTurnState : PlayerTurnState
{
    BatmanTurnState(Character@ c)
    {
        super(c);
        AddMotion(BATMAN_MOVEMENT_GROUP + "Turn_Right_90");
        AddMotion(BATMAN_MOVEMENT_GROUP + "Turn_Right_180");
        AddMotion(BATMAN_MOVEMENT_GROUP + "Turn_Left_90");
    }
};

class Batman : Player
{
    Batman()
    {
        super();
    }

    void AddStates()
    {
        stateMachine.AddState(BatmanStandState(this));
        stateMachine.AddState(BatmanRunState(this));
        stateMachine.AddState(BatmanTurnState(this));
        stateMachine.AddState(AnimationTestState(this));
    }
};

void CreateBatmanMotions()
{
    AssignMotionRig("Objects/batman/batman.mdl");

    String preFix = BRUCE_MOVEMENT_GROUP;
    Global_AddAnimation(preFix + "Stand_Idle");
    Global_AddAnimation(preFix + "Stand_Idle_01");
    Global_AddAnimation(preFix + "Stand_Idle_02");
    Global_CreateMotion(preFix + "Run_Forward", kMotion_Z, kMotion_Z, -1, true);

    int locomotionFlags = kMotion_XZR;
    Global_CreateMotion(preFix + "Turn_Right_90", locomotionFlags, kMotion_R, 16);
    Global_CreateMotion(preFix + "Turn_Right_180", locomotionFlags, kMotion_R, 25);
    Global_CreateMotion(preFix + "Turn_Left_90", locomotionFlags, kMotion_R, 14);
    Global_CreateMotion(preFix + "Walk_Forward", kMotion_Z, kMotion_Z, -1, true);

    Global_CreateMotion(preFix + "Stand_To_Walk_Right_90", locomotionFlags, kMotion_ZR, 21);
    Global_CreateMotion(preFix + "Stand_To_Walk_Right_180", locomotionFlags, kMotion_ZR, 25);
    Global_CreateMotion(preFix + "Stand_To_Run_Right_90", locomotionFlags, kMotion_ZR, 18);
    Global_CreateMotion(preFix + "Stand_To_Run_Right_180", locomotionFlags, kMotion_ZR, 25);
}

void CreateBatmanCombatMotions()
{
}

void AddBatmanCombatAnimationTriggers()
{
}

void AddBatmanAnimationTriggers()
{
}

