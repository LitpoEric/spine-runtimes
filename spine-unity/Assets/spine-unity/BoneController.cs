/******************************************************************************
 * Spine Runtimes Software License
 * Version 2.1
 * 
 * Copyright (c) 2013, Esoteric Software
 * All rights reserved.
 * 
 * You are granted a perpetual, non-exclusive, non-sublicensable and
 * non-transferable license to install, execute and perform the Spine Runtimes
 * Software (the "Software") solely for internal use. Without the written
 * permission of Esoteric Software (typically granted by licensing Spine), you
 * may not (a) modify, translate, adapt or otherwise create derivative works,
 * improvements of the Software or develop new applications using the Software
 * or (b) remove, delete, alter or obscure any trademarks or any copyright,
 * trademark, patent or other intellectual property or proprietary rights
 * notices on or in the Software, including any copy thereof. Redistributions
 * in binary or source form must include this license and terms.
 * 
 * THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL ESOTERIC SOFTARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

using System;
using System.IO;
using System.Collections.Generic;
using UnityEngine;
using Spine;

/// <summary>Sets a GameObject's transform to match a bone on a Spine skeleton.</summary>
[ExecuteInEditMode]
[AddComponentMenu("Spine/BoneController")]
public class BoneController : MonoBehaviour {
    public enum Mode
    {
        Follow,
        Override
    }
    public Mode mode=Mode.Follow;
	[System.NonSerialized]
	public bool valid;
    [HideInInspector]
    public SkeletonAnimation skeletonRenderer;
	public Bone bone;
    public bool followZPosition = true;
    //新增是否跟随postion
    public bool followPosition = true;
    public bool followBoneRotation = true;
    [HideInInspector]
    public bool transformLerpComplete;



    public SkeletonAnimation SkeletonRenderer
    {
		get { return skeletonRenderer; }
		set {
			skeletonRenderer = value;
			Reset();
		}
	}


	/// <summary>If a bone isn't set, boneName is used to find the bone.</summary>
	public String boneName;
	public bool resetOnAwake = true;
	protected Transform cachedTransform;
	protected Transform skeletonTransform;

	public void HandleResetRenderer (SkeletonRenderer skeletonRenderer) {
		Reset();
	}

	public void Reset () {
		bone = null;
		cachedTransform = transform;
		valid = skeletonRenderer != null && skeletonRenderer.valid;
		if (!valid)
			return;
		skeletonTransform = skeletonRenderer.transform;

		skeletonRenderer.OnReset -= HandleResetRenderer;
		skeletonRenderer.OnReset += HandleResetRenderer;

		if (Application.isEditor)
			DoUpdate();
	}

	public void Awake () {
		if (resetOnAwake)
			Reset();
	}

	void LateUpdate () {
		DoUpdate();
	}

	public void DoUpdate () {
		if (!valid) {
			Reset();
			return;
		}

		if (bone == null) {
			if (boneName == null || boneName.Length == 0)
				return;
			bone = skeletonRenderer.skeleton.FindBone(boneName);
			if (bone == null) {
				Debug.LogError("Bone not found: " + boneName, this);
				return;
			} else {

			}
		}

		Spine.Skeleton skeleton = skeletonRenderer.skeleton;
		float flipRotation = (skeleton.flipX ^ skeleton.flipY) ? -1f : 1f;
        if (mode == Mode.Follow) { 
		if (cachedTransform.parent == skeletonTransform) {
            if (followPosition) 
            {  cachedTransform.localPosition = new Vector3(bone.worldX, bone.worldY, followZPosition ? 0f : cachedTransform.localPosition.z);   }
			if (followBoneRotation) {
				Vector3 rotation = cachedTransform.localRotation.eulerAngles;
				cachedTransform.localRotation = Quaternion.Euler(rotation.x, rotation.y, bone.worldRotation * flipRotation);
			}

		} else {
			Vector3 targetWorldPosition = skeletonTransform.TransformPoint(new Vector3(bone.worldX, bone.worldY, 0f));
			if (!followZPosition)
				targetWorldPosition.z = cachedTransform.position.z;
            if (followPosition)
            {  cachedTransform.position = targetWorldPosition;  }
			if (followBoneRotation) {
				Vector3 rotation = skeletonTransform.rotation.eulerAngles;
				cachedTransform.rotation = Quaternion.Euler(rotation.x, rotation.y, skeletonTransform.rotation.eulerAngles.z + (bone.worldRotation * flipRotation));
			}
		}
        }
        else if (mode == Mode.Override)
        {
            if (transformLerpComplete)
                return;         
            //融合比例，原本应该是一个可以编辑的变量，现在似乎没有这个需求，所以赋值为1，不融合。
            float overrideAlpha =1f;
            if (followPosition)
            {
                    bone.worldX = Mathf.Lerp(bone.x, cachedTransform.localPosition.x, overrideAlpha);
                    bone.worldY = Mathf.Lerp(bone.y, cachedTransform.localPosition.y, overrideAlpha);
            }

            if (followBoneRotation)
            {
                    float angle = Mathf.LerpAngle(bone.Rotation, cachedTransform.localRotation.eulerAngles.z, overrideAlpha);
                    bone.Rotation = angle;
            }
        }
	}

    void UpdateLocal(SkeletonAnimation anim)
    { 
           transformLerpComplete = false; 
            DoUpdate();
    }

    void UpdateWorld(SkeletonAnimation anim)
    {
         DoUpdate();
    }

    void UpdateComplete(SkeletonAnimation anim)
    {
         DoUpdate();
    }

   
    void OnEnable()
    {
        //if (skeletonAnimation == null)
        //{
        //    skeletonAnimation = GetComponent<SkeletonAnimation>();
        //}

        if (skeletonRenderer != null)
        {
            skeletonRenderer.OnReset -= HandleResetRenderer;
            skeletonRenderer.OnReset += HandleResetRenderer;
            skeletonRenderer.UpdateLocal -= UpdateLocal;
            skeletonRenderer.UpdateLocal += UpdateLocal;
            skeletonRenderer.UpdateWorld -= UpdateWorld;
            skeletonRenderer.UpdateWorld += UpdateWorld;
            skeletonRenderer.UpdateComplete -= UpdateComplete;
            skeletonRenderer.UpdateComplete += UpdateComplete;

        }
    }

    void OnDisable()
    {
        if (skeletonRenderer != null)
        {
            skeletonRenderer.OnReset -= HandleResetRenderer;
            skeletonRenderer.UpdateLocal -= UpdateLocal;
            skeletonRenderer.UpdateWorld -= UpdateWorld;
            skeletonRenderer.UpdateComplete -= UpdateComplete;
        }
    }

}