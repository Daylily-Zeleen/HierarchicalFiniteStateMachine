
/*
	You can use 'Hfsm' to call the HFSM which contain this state , and call it's menbers.
	Please browse document to find API.
	
	== Note!! == 
	C# template can't auto replace class name, because the Template PlaceHolder grammar will be recognaize as C# grammar errs.
	Please Repalce you state class name Manually!!!
	
	== 注意！！== 
	C# 模板不能自动替换类名，因为模板占位符在会被识别为C#语法错误。
	请在创建改脚本后手动替换类名！！！
*/
using Godot;

namespace HFSMCSharpStateSctiptDemo{

// public class HfsmStateJump: HFSM.State
public class HfsmStateJump: HFSM.State
{
	/*
		CSharpScript State version unsupport auto append agents and the state which is nest this state.
		Because Godot can't get latest CSharpScript.source_code without reboot project( event if after build).
		This feature will be considered to add if godot fix this bug. 

		C# 状态脚本不支持自动添加 代理变量 和 内嵌该状态的状态变量。
		因为Godot不能获取最新的C#脚本代码，除非重启项目(即使在build之后)。
		只有Godot修复了这个bug，该特性才会被考虑添加进来。 

		You can add them mamually as follow:

		// "Node" can be replace as the class name of agent node.
		// "agent_node_name" must be a snake_case name of agent node, but it can be replace as agent node's name(usually it is PascalCase) if the HFSM is disable rename agent node name as snake_case.
		//     (HFSM -> Inspector-> Advanced Setting-> check Disable Rename To Snake Case)
		public Node agent_node_name{set;get;}
		public Node agent_node_name_other{set;get;}
		
		// "Reference" can be repalce as the class name of state which is nest this state if it is coded in C#, 
		// "fsm_nested_state_name" must be a name "'fsm_'+ the state name of state which is nest this state."
		public Reference fsm_nested_state_name{set;get;} 

		// "Node"可以被替换为代理节点的具体类名.
		// "agent_node_name"必须是代理节点的snake_case名称，但是当禁用HFSM重命名代理节点名称为snake_case的功能时，你可以将其替换为代理节点的名称（通常为PascalCase）。
		//     (HFSM -> 监视器 -> Advanced Setting-> 勾选 Disable Rename To Snake Case)
		public Node agent_node_name{set;get;}
		public Node agent_node_name_other{set;get;}
		
		// 如果嵌套该状态的状态附加了C#编写的脚本，"Reference"可以被替换为具体的类名。 
		// "fsm_nested_state_name"必须是 "'fsm_'+被该状态嵌套的父级状态名称."
		public Reference fsm_nested_state_name{set;get;} 
	*/
	
	// Define Agent node mamually;
	private Player player;
	
	/// <summary>
	/// This funcion will be called just once when the hfsm is generated.
	/// </summary>
	public override void Init(){
		// Your Init logic...
	}
	/// <summary>
	/// Will be called every time when entry this state.
	/// </summary>
	public override void Entry(){
		// Your Entry logic...
		player.StateLabel.Text = StateName;
		if(Input.IsActionJustPressed("ui_select")){
			var vel = player.Velocity;
			vel.y += Player.JumpSpeed;
			player.Velocity = vel;
			
			// Hfsm is a GDScript Node, so it can't be refer in C# Script, please use Call(), Get(), ..., to access it.
			Hfsm.Call("set_float", "velocity_length" ,player.Velocity.Length());
		}
	}
	/// <summary>
	/// Will be called every frame if the hfsm's process_type is setted at "Idle" or "Idle And Physics",
	/// and will be called every physics frame if the hfsm's process_type is setted at "Physics".
	/// (In order to ensure the function completeness)
	/// Note that this method will not be called if this state is an exit state.
	/// </summary>
	/// <param name="delta">The interval between last update, in second.</param>
	public override void Update(float delta){
		// Move control, different state's move logic are controlled at here. 
		var dir = Input.GetActionStrength("ui_right") - Input.GetActionStrength("ui_left");

		var vel = player.Velocity;
		vel.x = Mathf.Lerp(vel.x , dir * Player.MoveSpeed  , delta* Player.FloatHorizonAccel);
		vel.y += Player.Gravity * delta;
		player.Velocity = player.MoveAndSlide(vel, Vector2.Up);

		// Set hfsm's variable for transtion condition check.
		// Just for the transitions between "move" and "idle".
		// Others transitions is controlled by expression conditions, please refer the hfsm's graph for more.
		// Hfsm is a GDScript Node, so it can't be refer in C# Script, please use Call(), Get(), ..., to access it.
		Hfsm.Call("set_float", "velocity_length" ,player.Velocity.Length());
	}

	/// <summary>
	/// Will be called every physics frame if the hfsm's process_type is setted at "Physics" or "Idle And Physics",
	/// and will be called every frame if the hfsm's process_type is setted at "Idle".
	/// (In order to ensure the function completeness)
	/// Note that this method will not be called if this state is an exit state
	/// </summary>
	/// <param name="delta">The interval between last update, in second.</param>
	public override void PhysicsUpdate(float delta){
		// Your Physics Update logic...
		player.VelocityLengthLabel.Text = player.Velocity.Length().ToString();
	}
	/// <summary>
	/// Will be called every time when exit this state.
	/// Note that this method will be called immediatly after entry() if this state is an exit state.
	/// </summary>
	public override void Exit(){
		// Your Exit logic..
	}
}


}