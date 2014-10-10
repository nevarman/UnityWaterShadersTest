using UnityEngine;
using System.Collections;

public class Rotator : MonoBehaviour {
	public float speed = 10f;
	
	// Update is called once per frame
	void Update () {
		transform.Rotate(Vector3.right * Time.deltaTime * speed);
	}
}
