/**
 * Detail Screen Template
 *
 * A detail screen that:
 * - Fetches data based on route params
 * - Shows loading and error states
 * - Updates header dynamically
 */

import { useEffect, useState } from 'react';
import { View, Text, ScrollView, ActivityIndicator, StyleSheet } from 'react-native';
import { useLocalSearchParams, useNavigation } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';

interface ItemDetail {
  id: string;
  title: string;
  description: string;
  createdAt: string;
  author: {
    name: string;
    avatar: string;
  };
}

export default function DetailScreen() {
  const { id } = useLocalSearchParams<{ id: string }>();
  const navigation = useNavigation();
  const [item, setItem] = useState<ItemDetail | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function fetchItem() {
      try {
        setError(null);
        const response = await fetch(`/api/items/${id}`);
        if (!response.ok) {
          if (response.status === 404) {
            throw new Error('Item not found');
          }
          throw new Error('Failed to load item');
        }
        const data = await response.json();
        setItem(data);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error');
      } finally {
        setLoading(false);
      }
    }

    if (id) {
      fetchItem();
    }
  }, [id]);

  // Update header title when item loads
  useEffect(() => {
    if (item) {
      navigation.setOptions({
        title: item.title,
      });
    }
  }, [item, navigation]);

  if (loading) {
    return (
      <View style={styles.centered}>
        <ActivityIndicator size="large" color="#007AFF" />
      </View>
    );
  }

  if (error) {
    return (
      <View style={styles.centered}>
        <Text style={styles.errorText}>{error}</Text>
      </View>
    );
  }

  if (!item) {
    return (
      <View style={styles.centered}>
        <Text style={styles.errorText}>Item not found</Text>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>{item.title}</Text>
        <View style={styles.meta}>
          <Text style={styles.author}>By {item.author.name}</Text>
          <Text style={styles.date}>
            {new Date(item.createdAt).toLocaleDateString()}
          </Text>
        </View>
      </View>

      <View style={styles.content}>
        <Text style={styles.description}>{item.description}</Text>
      </View>
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  errorText: {
    color: '#FF3B30',
    fontSize: 16,
    textAlign: 'center',
  },
  header: {
    padding: 16,
    borderBottomWidth: 1,
    borderBottomColor: '#E5E5EA',
  },
  title: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#000',
    marginBottom: 12,
  },
  meta: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  author: {
    fontSize: 14,
    color: '#007AFF',
  },
  date: {
    fontSize: 14,
    color: '#8E8E93',
  },
  content: {
    padding: 16,
  },
  description: {
    fontSize: 16,
    lineHeight: 24,
    color: '#333',
  },
});
