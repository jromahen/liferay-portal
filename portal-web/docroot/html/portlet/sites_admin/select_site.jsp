<%--
/**
 * Copyright (c) 2000-2013 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/html/portlet/sites_admin/init.jsp" %>

<%
String p_u_i_d = ParamUtil.getString(request, "p_u_i_d");
long groupId = ParamUtil.getLong(request, "groupId");
boolean includeCompany = ParamUtil.getBoolean(request, "includeCompany");
boolean includeUserPersonalSite = ParamUtil.getBoolean(request, "includeUserPersonalSite");
String callback = ParamUtil.getString(request, "callback", "selectGroup");
String target = ParamUtil.getString(request, "target");

User selUser = PortalUtil.getSelectedUser(request);

PortletURL portletURL = renderResponse.createRenderURL();

portletURL.setParameter("struts_action", "/sites_admin/select_site");

if (selUser != null) {
	portletURL.setParameter("p_u_i_d", String.valueOf(selUser.getUserId()));
}

portletURL.setParameter("groupId", String.valueOf(groupId));
portletURL.setParameter("includeCompany", String.valueOf(includeCompany));
portletURL.setParameter("includeUserPersonalSite", String.valueOf(includeUserPersonalSite));
portletURL.setParameter("callback", callback);
portletURL.setParameter("target", target);
%>

<aui:form action="<%= portletURL.toString() %>" method="post" name="fm">
	<liferay-ui:header
		title="sites"
	/>

	<liferay-ui:search-container
		searchContainer="<%= new GroupSearch(renderRequest, portletURL) %>"
	>
		<liferay-ui:search-form
			page="/html/portlet/users_admin/group_search.jsp"
		/>

		<%
		GroupSearchTerms searchTerms = (GroupSearchTerms)searchContainer.getSearchTerms();

		LinkedHashMap<String, Object> groupParams = new LinkedHashMap<String, Object>();
		%>

		<liferay-ui:search-container-results>

			<%
			results.clear();

			if (groupId > 0) {
				List<Long> excludedGroupIds = new ArrayList<Long>();

				Group group = GroupLocalServiceUtil.getGroup(groupId);

				if (group.isStagingGroup()) {
					excludedGroupIds.add(group.getLiveGroupId());
				}
				else {
					excludedGroupIds.add(groupId);
				}

				groupParams.put("excludedGroupIds", excludedGroupIds);
			}

			groupParams.put("site", Boolean.TRUE);

			if (filterManageableGroups) {
				groupParams.put("usersGroups", user.getUserId());
			}

			int additionalSites = 0;

			if (includeCompany) {
				if (searchContainer.getStart() == 0) {
					results.add(company.getGroup());
				}

				additionalSites++;
			}

			if (includeUserPersonalSite) {
				if (searchContainer.getStart() == 0) {
					Group userPersonalSite = GroupLocalServiceUtil.getGroup(company.getCompanyId(), GroupConstants.USER_PERSONAL_SITE);

					results.add(userPersonalSite);
				}

				additionalSites++;
			}

			int start = searchContainer.getStart();

			if (searchContainer.getStart() > additionalSites) {
				start = searchContainer.getStart() - additionalSites;
			}

			int end = searchContainer.getEnd() - additionalSites;

			List<Group> sites = null;

			if (searchTerms.isAdvancedSearch()) {
				sites = GroupLocalServiceUtil.search(company.getCompanyId(), null, searchTerms.getName(), searchTerms.getDescription(), groupParams, searchTerms.isAndOperator(), start, end, searchContainer.getOrderByComparator());
				total = GroupLocalServiceUtil.searchCount(company.getCompanyId(), null, searchTerms.getName(), searchTerms.getDescription(), groupParams, searchTerms.isAndOperator());
			}
			else {
				sites = GroupLocalServiceUtil.search(company.getCompanyId(), null, searchTerms.getKeywords(), groupParams, start, end, searchContainer.getOrderByComparator());
				total = GroupLocalServiceUtil.searchCount(company.getCompanyId(), null, searchTerms.getKeywords(), groupParams, searchTerms.isAndOperator());
			}

			total += additionalSites;

			results.addAll(sites);


			pageContext.setAttribute("results", results);
			pageContext.setAttribute("total", total);
			%>

		</liferay-ui:search-container-results>

		<liferay-ui:search-container-row
			className="com.liferay.portal.model.Group"
			escapedModel="<%= true %>"
			keyProperty="groupId"
			modelVar="group"
			rowIdProperty="friendlyURL"
		>

			<%
			String rowHREF = null;

			if (Validator.isNull(p_u_i_d) || SiteMembershipPolicyUtil.isMembershipAllowed((selUser != null) ? selUser.getUserId() : 0, group.getGroupId())) {
				StringBundler sb = new StringBundler(10);

				sb.append("javascript:opener.");
				sb.append(renderResponse.getNamespace());
				sb.append(callback);
				sb.append("('");
				sb.append(group.getGroupId());
				sb.append("', '");
				sb.append(HtmlUtil.escapeJS(group.getDescriptiveName(locale)));
				sb.append("', '");
				sb.append(target);
				sb.append("'); window.close();");

				rowHREF = sb.toString();
			}
			%>

			<liferay-ui:search-container-column-text
				href="<%= rowHREF %>"
				name="name"
				value="<%= HtmlUtil.escape(group.getDescriptiveName(locale)) %>"
			/>

			<liferay-ui:search-container-column-text
				href="<%= rowHREF %>"
				name="type"
				value="<%= LanguageUtil.get(pageContext, group.getTypeLabel()) %>"
			/>
		</liferay-ui:search-container-row>

		<liferay-ui:search-iterator />
	</liferay-ui:search-container>
</aui:form>

<aui:script>
	Liferay.Util.focusFormField(document.<portlet:namespace />fm.<portlet:namespace />name);
</aui:script>