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
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(SkeletonAnimation))]
public class SkeletonAnimationInspector : SkeletonRendererInspector
{
	protected SerializedProperty animationName, loop, timeScale, currentAnimTime,currentAnimFrame;

		protected override void OnEnable ()
		{
				base.OnEnable ();
				animationName = serializedObject.FindProperty ("_animationName");
				loop = serializedObject.FindProperty ("loop");
				timeScale = serializedObject.FindProperty ("timeScale");
				currentAnimTime = serializedObject.FindProperty ("currentAnimTime");
				currentAnimFrame = serializedObject.FindProperty ("currentAnimFrame");
		}

		protected override void gui ()
		{
				base.gui ();

				SkeletonAnimation component = (SkeletonAnimation)target;
				if (!component.valid)
						return;

				// Animation name.
				String[] animations = new String[component.skeleton.Data.Animations.Count + 1];
				animations [0] = "<None>";
				int animationIndex = 0;
				for (int i = 0; i < animations.Length - 1; i++) {
						String name = component.skeleton.Data.Animations [i].Name;
						animations [i + 1] = name;
						if (name == animationName.stringValue)
								animationIndex = i + 1;
				}
		
				EditorGUILayout.BeginHorizontal ();
				EditorGUILayout.LabelField ("Animation", GUILayout.Width (EditorGUIUtility.labelWidth));
				animationIndex = EditorGUILayout.Popup (animationIndex, animations);
				EditorGUILayout.EndHorizontal ();

				String selectedAnimationName = animationIndex == 0 ? null : animations [animationIndex];
				component.AnimationName = selectedAnimationName;
				animationName.stringValue = selectedAnimationName;

				EditorGUILayout.PropertyField (loop);
				EditorGUILayout.PropertyField (timeScale);
				component.timeScale = Math.Max (component.timeScale, 0);
				//自己的编辑器
				if (animationIndex > 0) {
						float animDuration=component.skeleton.Data.Animations [animationIndex - 1].Duration;
						EditorGUILayout.PropertyField (currentAnimTime);
						//帧设置和显示页面
						EditorGUILayout.BeginHorizontal();
						frame=EditorGUILayout.IntField("Current Anim Frame",(int)Math.Min(frame,animDuration*30));
						float loadWidth = GUI.skin.label.CalcSize (new GUIContent ("load")).x + 20;
						if (GUILayout.Button ("load", GUILayout.Width (loadWidth))) {
							if (component.skeletonDataAsset != null) {
								component.currentAnimTime=(float)(frame/(30.0*component.timeScale));
							}
						}
						EditorGUILayout.EndHorizontal();
						//END
						float time = Math.Max (component.currentAnimTime, 0);
						float maxAnimTime = (float)(animDuration/ component.timeScale);
						component.currentAnimTime = GUILayout.HorizontalSlider (Math.Min (time, maxAnimTime), 0f, maxAnimTime);
						if (component.currentAnimTime != lastMaxAnimTime) {
								component.PlayTo ();
								lastMaxAnimTime = component.currentAnimTime;
								frame=(int)(component.currentAnimTime*30*component.timeScale);
						}
						float reloadWidth = GUI.skin.label.CalcSize (new GUIContent ("Reload")).x + 20;
						if (GUILayout.Button ("Reload", GUILayout.Width (reloadWidth))) {
								if (component.skeletonDataAsset != null) {
										if (component.skeletonDataAsset.atlasAsset != null)
												component.skeletonDataAsset.atlasAsset.Reset ();
										component.skeletonDataAsset.Reset ();
								}
								component.Reset ();
						} 
				}
				//END
		}

		private float lastMaxAnimTime = 0f;
		private float frame;
}
