class LdapSync
  class Roles
    extend LdapSync::Common

    class << self

      NINE_UBERZEIT_ADMIN_DEPARTMENTS = %w(Management Administration)
      if Rails.env.development?
        NINE_UBERZEIT_ADMIN_DEPARTMENTS << 'Development'
      end

      def sync
        sync_all_roles
      end

      private

      def sync_all_roles
        drop_revoked_roles
        ensure_roles
      end

      def drop_revoked_roles
        User.all.each do |user|
          revoked_roles = user.roles.reject do |role|
            is_role_valid = false

            if role.name == 'admin' && admin_in_ldap?(user)
              is_role_valid = true
            end

            if role.name == 'team_leader' && role.resource_id
              team = Team.find(role.resource_id)
              if team_leader_in_ldap?(user, team)
                is_role_valid = true
              end
            end

            is_role_valid
          end

          user.roles.delete(revoked_roles)
        end
      end

      def ensure_roles
        Department.find_all.each do |department|
          if NINE_UBERZEIT_ADMIN_DEPARTMENTS.include?(department.cn)
            each_user_in_person_list(department.people) { |user| user.add_role(:admin) }
            each_user_in_person_list(department.managers) { |user| user.add_role(:admin) }
          end

          each_user_in_person_list(department.managers) do |user|
            team = Team.find_by_uid(department.id)
            raise "Team not found for department #{department}" unless team
            user.add_role(:team_leader, team)
          end
        end
      end

      def admin_in_ldap?(user)
        person = Person.find_by_mail(user.uid)
        person.departments.any? { |department| NINE_UBERZEIT_ADMIN_DEPARTMENTS.include?(department.cn) }
      end

      def team_leader_in_ldap?(user, team)
        person = Person.find_by_mail(user.uid)
        department = Department.find(team.uid)
        return false if person.nil? or department.nil?
        department.managers.include?(person)
      end
    end
  end
end

