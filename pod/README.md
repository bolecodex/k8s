<p><strong>Context</strong><br>
You have been asked to create a new ClusterRole for a deployment pipeline and bind it to a specific ServiceAccount scoped to a specific namespace.</p>
<p><strong>Task</strong><br>
Create a new ClusterRole named deployment-clusterrole, which only allows to create the following resource types:<br>
✑ Deployment<br>
✑ Stateful Set<br>
✑ DaemonSet<br>
Create a new ServiceAccount named cicd-token in the existing namespace app-team1.<br>
Bind the new ClusterRole deployment-clusterrole to the new ServiceAccount cicd-token, limited to the namespace app-team1.</p>

