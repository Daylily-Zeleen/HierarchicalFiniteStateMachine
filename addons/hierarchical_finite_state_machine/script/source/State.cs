// ##############################################################################
// #	Copyright (C) 2021 Daylily-Zeleen  735170336@qq.com.                                                   
// #
// #	DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
// #
// #	Hirerarchical Finite State Machine(HFSM - Full Version).   
// #     
// #                 
// #	This file is part of HFSM - Full Version.
// #                                                                                                                       *
// #	HFSM - Full Version is a Godot Plugin that can be used freely except in any 
// #form of dissemination, but the premise is to donate to plugin developers.
// #Please refer to LISENCES.md for more information.
// #                                                                   
// #	HFSM - Full Version是一个除了以任何形式传播之外可以自由使用的Godot插件，前提是向插件开
// #发者进行捐赠，具体许可信息请见 LISENCES.md.
// #
// #	This is HFSM‘s full version ,But there are only a few more unnecessary features 
// #than the trial version(please read the READEME.md to learn difference.).If this 
// #plugin is useful for you,please consider to support me by getting the full version.
// #If you do not want to donate,please consider to use the trial version.
// #
// #	虽然称为HFSM的完整版本，但仅比试用版本多了少许非必要的功能(请阅读README.md了解他们的差异)。
// #如果这个插件对您有帮助，请考虑通过获取完整版本来支持插件开发者，如果您不想进行捐赠，请考虑使
// #用试用版本。
// #
// # Trail version link : 
// #	https://gitee.com/y3y3y3y33/HierarchicalFiniteStateMachine
// #	https://github.com/Daylily-Zeleen/HierarchicalFiniteStateMachine
// # Sponsor link : 
// #	https://afdian.net/@Daylily-Zeleen
// #	https://godotmarketplace.com/?post_type=product&p=37138      
// #                     
// #	@author   Daylily-Zeleen                                                     
// #	@email    daylily-zeleen@qq.com                                              
// #	@version  0.8(版本号)                                                    
// #	@license  Custom License(Read LISENCES.TXT for more details)
// #                                                                      
// #----------------------------------------------------------------------------
// #  Remark         : this is the State class's script,you can see it API in this script。
// #					这是HFSM类的脚本，您可以在此脚本中查看State类的API。                                            
// #----------------------------------------------------------------------------
// #  Change History :                                                          
// #  <Date>     | <Version> | <Author>       | <Description>                   
// #----------------------------------------------------------------------------
// #  2022/07/02 | 0.8   | Daylily-Zeleen      | Create file                 
// #----------------------------------------------------------------------------
// #                                                                            
// ##############################################################################
using Godot;
using Godot.Collections;

namespace HFSM
{
    public class State : Reference
    {
        private static readonly GDScript HFSMScript = GD.Load<GDScript>("res://addons/hierarchical_finite_state_machine/script/hfsm.gd");
        /// <summary>
        /// Read only.the name of this State.
        /// </summary>
        /// <value></value>
        public string StateName
        {
            set
            {
                if (stateName.Empty() && !value.Empty())
                {
                    // GD.Print("set name "+ value);
                    stateName = value;
                }
                // else
                // {
                //     GD.PrintErr("HFSM: Can not set state name'"+value+"' when running.-cs");
                // }
            }
            get {
                return stateName;
            }
        }
        private string stateName = "";

        /// <summary>
        /// Read only.the instance of HFSM,which contain this State.
        /// </summary>
        /// <value></value>
        public Node Hfsm
        {
            get => _hfsm;
            set
            {
                if (_hfsm == null && value != null &&
                        value.GetScript() == HFSMScript)
                {
                    _hfsm = value;
                    var pNameList = new Array<string>();
                    var agents = (Dictionary)_hfsm.Get("agents");
                    foreach (Dictionary p in ((CSharpScript)GetScript()).GetScriptPropertyList())
                    {
                        pNameList.Add((string)p["name"]);
                    }
                    foreach (string agent in agents.Keys)
                    {
                        if (agent != "null" && pNameList.Contains(agent))
                        {
                            this.Set(agent, agents[agent]);
                        }
                    }
                    Init();
                    foreach (Dictionary property in ((CSharpScript)GetScript()).GetScriptPropertyList())
                    {
                        var pName = (string)property["name"];
                        if (!InternalProperties.Contains(pName) && !agents.Contains(pName))
                        {
                            _property_to_default_value[pName] = this.Get(pName);
                        }
                    }
                }
                // else
                // {
                //     GD.PrintErr("HFSM err:"+state_name+" can not set state property 'hfsm'.-cs");
                // }
            }
        }
        static private readonly Array<string> InternalProperties = new Array<string>{"_property_to_default_value", 
                "state_name", "_state_type", "hfsm", "_nested_fsm", 
                "StateName", "stateName", "HFSMScript", "Hfsm", "InternalProperties", "_hfsm",};
        private Node _hfsm = null;


        /// <summary>
        /// Read only.if true,this State is exited.
        /// </summary>
        /// <value></value>
        public bool IsExited{ private set; get; }


        /// <summary>
        /// manually exit this State.
        /// @note : if this state is exited,it will not update and physics update anymore,
        /// can trigger auto transit,if the auto transition which start State is this,
        /// and auto transit mode is "Manual Exit".
        /// </summary>
        public void ManualExit()
        {
            if (!IsExited)
            {
                IsExited = true;
                Exit();
            }
        }


        public virtual void Init() {if(_state_type==0){} }
        public virtual void Entry() { }
        public virtual void Update(float delta) { }
        public virtual void PhysicsUpdate(float delta) { }
        public virtual void Exit() { }




        // === Internal ====
        // 以下命名为了兼容GDS逻辑功能
        private string state_name
        {
            set {
                StateName = value;
            }
            get => StateName;
        }

        private bool is_exited
        {
            get => IsExited;
        }

        private Node hfsm
        {
            set => Hfsm = value;
            get => Hfsm;
        }

        private int _state_type = 0; //0 normal,1 entry ,2 exit 
        private Dictionary<string, object> _property_to_default_value = new Dictionary<string, object>();

        private Reference _nested_fsm
        {
            set
            {
                if (nestedFsm == null)
                {
                    nestedFsm = value;
                }
                else
                {
                    GD.PrintErr("HFSM:Can not set state property '_nested_fsm' when running.");
                }
            }
            get => nestedFsm;
        }
        private Reference nestedFsm;


        private Array<Reference> _transition_list =new Array<Reference>();
        private bool _reset_when_entry { set; get; }
        private void _entry()
        {
            IsExited = false;
            if (_reset_when_entry) _reset();
            foreach (Reference transition in _transition_list)
            {
                transition.Call("refresh");
            }
            
            Entry();
            if (_nested_fsm != null) _nested_fsm.Call("_entry");
        }

        private void _update(float delta)
        {
            if (!IsExited) Update(delta);
        }

        private void _physics_update(float delta)
        {
            if (!IsExited) PhysicsUpdate(delta);
        }
        private void _exit(bool is_terminated_by_upper_level = false)
        {
            if (!IsExited)
            {
                IsExited = true;
                if (!is_terminated_by_upper_level)
                {
                    var queue = new Array<Reference>() { this };
                    while (queue[queue.Count-1].Get("_nested_fsm") != null && (bool)((Reference)(queue[queue.Count-1].Get("_nested_fsm"))).Get("is_running"))
                    {
                        queue.Add((Reference)((Reference)(queue[queue.Count-1].Get("_nested_fsm"))).Get("_current_state"));
                    }
                    while (queue.Count > 0)
                    {
                        queue[queue.Count-1].Call("_exit", true);
                        queue.RemoveAt(queue.Count-1);
                    }
                }
                else
                {
                    if (_nested_fsm != null && (bool)_nested_fsm.Get("is_running"))
                    {
                        _nested_fsm.Call("_exit_by_state");
                    }
                }
                Exit();
            }
        }
        private void _reset()
        {
            foreach (string pName in _property_to_default_value.Keys)
            {
                Set(pName, _property_to_default_value[pName]);
            }
        }
    }
}
