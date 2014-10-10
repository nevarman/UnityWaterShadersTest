using UnityEngine;
using System.Collections;

public class StressTest : MonoBehaviour {
	public int numOf = 100;
	public bool addScript = false;
	public Light dirLight;
	int counter=0;
	// Use this for initialization
	void Start () {
		Application.targetFrameRate = 60;

	}
	void OnGUI()
	{
		// Can make up to 800 cubes without shadows and with added scripts, tested on Nexus 4 and Galaxy Note2
		GUI.color = Color.red;
		addScript = GUI.Toggle(new Rect(160,10,100,50),addScript,"Add script");
		if(GUI.Button(new Rect(10,10,150,80),"Generate 100"))
		{
			for(int i = 0; i < numOf; i++ )
			{
				var cube = GameObject.CreatePrimitive( PrimitiveType.Cube );
				Destroy( cube.GetComponent<BoxCollider>() );
				cube.transform.position = new Vector3(i % 10, cube.transform.position.y + counter,i - 10);
				if(addScript)
					cube.AddComponent<Rotator>();
			}
			counter ++;
		}
		GUI.Label(new Rect(10,100,300,50),string.Format("Num of cubes: {0}",counter*numOf));

		if(GUI.Button(new Rect(10,150,150,80),"Shadow switch"))
		{
			if(dirLight.shadows == LightShadows.None)
				dirLight.shadows = LightShadows.Hard;
			else 
				dirLight.shadows = LightShadows.None;
		}
	}
}
