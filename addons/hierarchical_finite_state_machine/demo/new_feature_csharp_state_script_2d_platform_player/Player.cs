using Godot;
using System;

namespace HFSMCSharpStateSctiptDemo{
    

public class Player : KinematicBody2D
{
    
    public Vector2 Velocity {set;get;} = Vector2.Zero ;
    public const float Gravity = 400f ;
    public const float Accel = 15.0f ;
    public const float JumpSpeed = -300f;
    public const float MoveSpeed = 150f;
    public const float FloatHorizonAccel = 50f;

    public Label StateLabel{get; private set;}
    public Label VelocityLengthLabel{get; private set;}



    public override void _Ready()
    {
        StateLabel = GetNode<Label>("StateLabel");
        VelocityLengthLabel = GetNode<Label>("VelocityLengthLabel");
    }

}

}