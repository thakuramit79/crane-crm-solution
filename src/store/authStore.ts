import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import { AuthState, User } from '../types/auth';
import { supabase } from '../lib/supabase';

interface AuthStore extends AuthState {
  login: (email: string, password: string) => Promise<void>;
  logout: () => Promise<void>;
  checkAuth: () => Promise<boolean>;
}

export const useAuthStore = create<AuthStore>()(
  persist(
    (set, get) => ({
      token: null,
      user: null,
      isAuthenticated: false,
      error: null,
      
      login: async (email: string, password: string) => {
        try {
          set({ error: null });
          
          const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password,
          });
          
          if (error) throw error;
          
          if (!data.session || !data.user) {
            throw new Error('No session or user data returned');
          }
          
          const userRole = data.user.user_metadata.role || 'operator';
          
          const user: User = {
            id: data.user.id,
            name: data.user.user_metadata.name || data.user.email?.split('@')[0] || 'User',
            email: data.user.email!,
            role: userRole,
            avatar: data.user.user_metadata.avatar,
          };
          
          set({ 
            token: data.session.access_token,
            user,
            isAuthenticated: true,
          });
        } catch (error) {
          set({ error: (error as Error).message });
          throw error;
        }
      },
      
      logout: async () => {
        try {
          const { error } = await supabase.auth.signOut();
          if (error) throw error;
          
          set({ token: null, user: null, isAuthenticated: false, error: null });
        } catch (error) {
          console.error('Logout error:', error);
          // Still clear the store even if the API call fails
          set({ token: null, user: null, isAuthenticated: false, error: null });
        }
      },
      
      checkAuth: async () => {
        try {
          const { data: { session }, error } = await supabase.auth.getSession();
          
          if (error || !session) {
            set({ token: null, user: null, isAuthenticated: false });
            return false;
          }
          
          const userRole = session.user.user_metadata.role || 'operator';
          
          const user: User = {
            id: session.user.id,
            name: session.user.user_metadata.name || session.user.email?.split('@')[0] || 'User',
            email: session.user.email!,
            role: userRole,
            avatar: session.user.user_metadata.avatar,
          };
          
          set({
            token: session.access_token,
            user,
            isAuthenticated: true,
          });
          
          return true;
        } catch (error) {
          console.error('Auth check error:', error);
          set({ token: null, user: null, isAuthenticated: false });
          return false;
        }
      },
    }),
    {
      name: 'auth-storage',
      partialize: (state) => ({ token: state.token }),
    }
  )
);